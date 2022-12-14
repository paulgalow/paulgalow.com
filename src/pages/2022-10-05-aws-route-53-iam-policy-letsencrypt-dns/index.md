---
slug: aws-route-53-iam-policy-letsencrypt-dns
title: "AWS Route 53 least privilege IAM policy for Let's Encrypt DNS challenge"
date: "2022-10-05"
---

![A person entering a gate to a huge castle in the clouds](./illustration-dalle2.png)

If you are using AWS Route 53 as your DNS provider, you might have been surprised after consulting the service's documentation for IAM permissions.

Until recently, IAM permissions for DNS entries could not be tied down further than to the level of a hosted zone. An overly broad set of permissions was required, even if you only wanted to make a small change, like adding or deleting a TXT record.

This became quite apparent when using non-public-facing tools like reverse proxies. For example, I have been using [Traefik](https://traefik.io/) to facilitate access to internal services. The easiest way for me to automate TLS certificate management was using wildcard certificates. This and the fact that the service is not exposed to the Internet is a perfect use case for [Let's Encrypt's DNS challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge). No need to open any ports. Everything is handled at the DNS level. Not to mention, this is the only challenge type for LE wildcard certificates anyway. Perfect. But I always had a bad feeling about provisioning those overly broad AWS permissions. What if the reverse proxy gets compromised? An attacker would be able to take over all of my domain's records.

Fortunately, [AWS just released an update](https://aws.amazon.com/about-aws/whats-new/2022/09/amazon-route-53-support-dns-resource-record-set-permissions/) that lets us now use additional IAM permission conditions to create a very tightly scoped IAM policy with least privilege access. Let me show you how:

The main change is in the `route53:ChangeResourceRecordSets` API call. We can add a list of allowed record names and their types ([among other options](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/specifying-rrset-conditions.html)). So how do we limit this API call to Let's Encrypt? All Let's Encrypt does is add (and remove) a DNS TXT entry with the key of `_acme-challenge.<your-domain-name.tld>`.

Here is an example of the specific IAM policy action. Replace `Z11111112222222333333` with your hosted zone ID and `example.com` with your domain name:

```json{diff}
{
  "Effect": "Allow",
  "Action": ["route53:ChangeResourceRecordSets"],
  "Resource": "arn:aws:route53:::hostedzone/Z11111112222222333333",
+   "Condition": {
+     "ForAllValues:StringEquals": {
+       "route53:ChangeResourceRecordSetsNormalizedRecordNames": [
+         "_acme-challenge.example.com"
+       ],
+       "route53:ChangeResourceRecordSetsRecordTypes": ["TXT"]
+     }
+   }
}
```

Unfortunately, the complete IAM policy required varies from case to case since different ACME clients use different AWS API calls to achieve the same outcome.

## Example policy: acme.sh (used by OPNsense ACME Client plugin)

Here is an example policy for [acme.sh](https://github.com/acmesh-official/acme.sh) that I have been using with the OPNsense ACME Client (using the os-acme-client plugin). In this case, I wanted to issue certificates for single domains and wildcard certificates at the same time. I achieved this by changing two parts of the policy:

1. Swapping the `ForAllValues:StringEquals` condition with `ForAllValues:StringLike`
2. Changing the allowed record name from a specific domain to including a wildcard `*` character

```json{diff}
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["route53:ListHostedZones"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["route53:GetHostedZone", "route53:ListResourceRecordSets"],
      "Resource": "arn:aws:route53:::hostedzone/Z11111112222222333333"
    },
    {
      "Effect": "Allow",
      "Action": ["route53:ChangeResourceRecordSets"],
      "Resource": "arn:aws:route53:::hostedzone/Z11111112222222333333",
      "Condition": {
-         "ForAllValues:StringEquals": {
+         "ForAllValues:StringLike": {
          "route53:ChangeResourceRecordSetsNormalizedRecordNames": [
-             "_acme-challenge.example.com"
+             "_acme-challenge.*example.com"
          ],
          "route53:ChangeResourceRecordSetsRecordTypes": ["TXT"]
        }
      }
    }
  ]
}
```

## Example policy: Traefik

And here is an example for using Traefik with its [Route 53 dnsChallenge provider](https://go-acme.github.io/lego/dns/route53/).

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["route53:ListResourceRecordSets"],
      "Resource": ["arn:aws:route53:::hostedzone/Z11111112222222333333"]
    },
    {
      "Effect": "Allow",
      "Action": ["route53:ChangeResourceRecordSets"],
      "Resource": ["arn:aws:route53:::hostedzone/Z11111112222222333333"],
      "Condition": {
        "ForAllValues:StringEquals": {
          "route53:ChangeResourceRecordSetsNormalizedRecordNames": [
            "_acme-challenge.example.com"
          ],
          "route53:ChangeResourceRecordSetsRecordTypes": ["TXT"]
        }
      }
    }
  ]
}
```

## Bonus: Lock down your policies even further by using fixed IP addresses

If you are using this for internal networks and have a static IP address assigned to your WAN connection you can use that contextual information to deny any AWS API calls not originating from that IP address. I have created a managed policy that I can easily add to an IAM entity like a user, group, or role. IAM will aggregate all policies attached to an IAM entity and evaluate them in total.

Here is an example that denies all access if a request does not originate from either one of our specified IP addresses `20.20.20.20` or `30.30.30.30`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIfNotFromSpecifiedIps",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": ["20.20.20.20/32", "30.30.30.30/32"]
        },
        "BoolIfExists": {
          "aws:PrincipalIsAWSService": "false",
          "aws:ViaAwsService": "false"
        }
      }
    }
  ]
}
```

The `BoolIfExists` condition is optional but useful to make sure AWS services (like KMS) can still use this policy on your behalf.

Updated December 2022.
