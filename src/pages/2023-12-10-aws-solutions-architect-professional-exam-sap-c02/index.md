---
slug: aws-solutions-architect-professional-exam-sap-c02
title: "AWS Certified Solutions Architect Professional (SAP-C02): Recommendations for passing the exam"
date: "2023-12-10"
---

![A man studying in a cabin in the woods](./studying.png)

"That's it, I'm out". Those were my initial thoughts when I attempted to answer the first questions of my exam. I had just waited an hour to finally start the exam. One hour of waiting in lines and talking to support people online. Technical difficulties. I was stressed. But then things cleared up and I pushed through, question by question, until the end. And lo and behold! I passed, and I was over the moon.

So I'd like to share a bit about my background, what I did to prepare, and some tips and recommendations I discovered along the way.

## My background

I've been architecting, building and administrating AWS-based greenfield solutions for traditional (EC2, Fargate) and event-driven workloads (Serverless, Lambda, DynamoDB, etc.) since 2015. Over time, I've honed my skills in a small company with an increasingly regulated environment. However, I had little exposure to more enterprise-grade and hybrid solutions. Knowing this helped me identify my strengths and weaknesses to focus my exam preparation. I've been an AWS Certified Solutions Architect – Associate since 2016 with recertifications along the way. If you haven't passed this exam, I would highly recommend taking that one first as it will teach you the basics of many AWS services.

## Overview of SAP-C02

In 2022, AWS updated their Professional level exam to a new exam type with the exam code SAP-C02. I didn't take the old exam but from what I could find, there weren't many groundbreaking changes. To me, it felt more like an update and a shift to include newer services.

There are now four content domains to focus on:

- Domain 1: Design Solutions for Organizational Complexity (26%)
- Domain 2: Design for New Solutions (29%)
- Domain 3: Continuous Improvement for Existing Solutions (25%)
- Domain 4: Accelerate Workload Migration and Modernization (20%)

Also, according to the [official SAP-C02 exam guide](https://d1.awsstatic.com/training-and-certification/docs-sa-pro/AWS-Certified-Solutions-Architect-Professional_Exam-Guide_C02.pdf), the scope of AWS services has expanded from approximately 100 to 150 services.

## How I prepared

### Ongoing practice: Taking notes

Early in my career, I discovered the benefits of a personal note-taking system. I currently use Obsidian and have built up an extensive set of notes over the years. These come in handy when reviewing practical knowledge. I write down features and limitations and refer to other resources such as articles or videos. Limitations are especially helpful for the exam because AWS will test your knowledge around the edges of service capabilities. More on that later. This practice of writing things down as I learn them helps me solidify my knowledge over time. It is an ongoing practice that helps me reduce the amount of stuff I have to learn specifically for the exam.

For AWS I have a separate notebook/folder with subfolders and lots of notes around services. This is my general pool of AWS knowledge, something I use every day to do my job, and the most detailed source of knowledge I maintain.

For the exam, I have a separate note where I jot down knowledge gaps and mistakes I keep making (and there are a lot). I will also cross-reference from here to my general AWS knowledge pool.

### Two training modes to alternate

Early on in my AWS certification journey, I made the mistake of putting off practice exams for too long. I had a false sense of confidence in my abilities and only found out about my gaps when I actually started taking practice exams. This led to my training plan consisting of two modes: 1) In-depth topical training and 2) Real-world exam simulation.

#### Mode 1: In-depth topical training

This is the mode I start with and spend most of my time in. In this mode, I deliberately ignore time constraints and instead answer questions one at a time, carefully reviewing answers and explanations and then taking time to read/watch/do some more to further my understanding. This includes diving into AWS documentation, watching YouTube videos like re:Invent talks, and tutorial videos and last but not least trying things out in the AWS Console. I cannot stress that last point enough: Sometimes I find that just 10 minutes in the Console creates a much more robust mental model of a service than hours of watching and reading alone could ever do.

This type of learning keeps me motivated and interested, because once I get a question wrong, I'm more engaged and want to find the right answer.

#### Mode 2: Real-world exam simulation

One of my biggest exam challenges is the ability to stay focused for three (and a half) hours at a time. Too often, my mind wanders and I realize that I didn't really understand what I just read. When I realize this, I go back and review the text. If I don't, I might miss some crucial little detail that could lead me to the wrong answer. Many questions try to trick you and lead you astray. So learning to concentrate for long periods of time is crucial.

So what I do is take 1 to 1,5 hours at a time to answer as many questions as possible. Later, I would review each question and research any missing gaps. Such a consecutive review could take several days but I would recognize my tendency to skip some of the finer details when faced with a long list of wrong answers to review. At that point, I would go back to mode 1 to make sure what I had read stuck.

## What to focus on

AWS provides an overwhelming amount of information that is often dense and difficult to understand. Just take a look at the [EC2 User Guide for Linux instances](https://docs.aws.amazon.com/pdfs/AWSEC2/latest/UserGuide/ec2-ug.pdf#concepts) which is nearly 2600 pages long. This is an extreme example, but even 300 pages per service does not scale to 150 services. Not to mention that these guides change over time. Taking an online course is highly recommended to provide the baseline, but in my experience it is not enough. Here is why:

The typical learning path of courses, videos, and documentation leads to a _siloed view of each service_. You learn about X and Y, but you don't know _how_ X connects with Y, and when and how to choose Z instead. This kind of knowledge is much harder to come by, much of it comes from experience, but hands-on labs and whitepapers can also be valuable.

### Tip #1: Focus on the how, not just the what

For me, it is much harder to learn a service that I have no hands-on experience with. So I try to challenge myself by actually building something with the services I don't know. At the very least, I will try out the console and click around to get a better feel for a service. Having the knowledge to set something up is much more sticky than trying to remember a series of steps written down in documentation. Just seeing someone else do it can also be valuable, as you get much more context and tacit knowledge that can't be taught otherwise.

Example: How to set up Transit Gateway? What are the steps involved?

### Tip #2: Focus on the combination of services

With the Associate level exam in mind, the biggest difference for me was the requirement to cover multiple services in one question. Most questions require you to _combine and apply your knowledge to at least two services at once_.

Example: How to set up a Transit Gateway (service one) in combination with Direct Connect (service two) in two different regions (context).

### Tip #3: Focus on the tradeoffs and differences between services

Amazon's cross-functional company structure and microservices architecture has led to its famous two-pizza team rule. One consequence of this decentralized approach has been a wild proliferation of AWS services, sometimes with overlapping functionality. In most cases, there is more than one way to achieve the same result. I think of this focus on primitives, not products as tools like Lego bricks. So you have to know what each tool is good for and when to use another. This means _knowing the tradeoffs and differences_ between services.

Examples: When to use which?

- Transit Gateway vs. VPC peering vs. VPC sharing
- Application Migration Service vs. Database Migration Service?
- AppRunner vs. Lambda vs. Fargate?
- DataSync vs. Storage Gateway?
- ElastiCache for Memcached vs. Redis vs. MemoryDB?

## Scheduling the exam

Are you a non-native English speaker like I me? If so, be sure to request an exam accommodation in advance to get an extra 30 minutes. Huge shout out to [Luciano Mammino](https://loige.co/aws-solution-architect-professional-exam-notes-tips) for bringing this to my attention. Having those extra 30 minutes in the exam gave me another 15 minutes at the end to review some marked questions.

## Online or offline?

I usually prefer online to offline exams, but let me tell you taking an online exam with Pearson OnVue is not for the faint of heart. I've done both in my AWS certification journey, so here's a quick comparison of some of the pros and cons for each:

### Offline: Pros and Cons

Pros: Taking an exam offline is like using an AWS managed service. A lot of responsibility falls on the test center. They have to take care of the internet connection, provide the right space, set up a testing device that you can use without having to install intrusive software on your computer, have proper lighting, etc. If something doesn't work on their end, you won't be penalized. You don't have to stare at the screen all the time, you can take a bathroom break (at the expense of your exam time), and you can take notes on a piece of paper.

Cons: For me, the biggest disadvantage is the shared environment. As with AWS, you may end up on a busy host that day with people coming in and out of the room. You are also subject to the noise of other people around you, which I am unfortunately very sensitive to.

### Online: Pros and Cons

Pros: The biggest advantage of taking the exam at home for me is the familiar environment. I can do it from the comfort of my home and I don't have to travel anywhere. No unfamiliar environment. Depending on your living situation, it may be easier to find a quiet testing environment, because you have more control over your surroundings. Still, make sure you know your environment and when you have the best chance of getting some quiet time.

Cons: Like hosting a service yourself, you have to take care of things yourself. Make sure your internet connection is stable, have a closed room where no one can enter during the exam. You must install intrusive software that monitors your computer, including your webcam and microphone. You must run a system test before the exam to make sure your setup is compatible with the exam software. You can't take a bathroom break, you have to keep your eyes on the screen at all times, you can't talk directly to a support person, you have to rely on chat or internet voice calls.

### Tips for taking the exam online

If you decide to take the exam online, here are some tips to help you avoid problems:

- Don't use a wide-screen/large monitor
  - The Pearson OnVue software does not currently have an option to limit the line width, which means that all text will run from the far left to the far right of your screen, which can be very difficult to read. Also, you might look suspicious if your eyes are constantly moving from left to right.
- Make sure you can read the text
  - When you take the Pearson OnVue system test, it emulates a real exam environment. Make sure you can easily read the text, as I have not found a way to increase the font size on macOS. The keyboard shortcut mentioned in the preparation guide did not work for me.
- Make sure you have exactly one webcam (driver) installed on your system
  - I ran into a problem where my online proctors could not see my video feed, so my exam started an hour late. I suspect this had something to do with the OBS virtual webcam installed on my system
- Remember the keyboard shortcuts to quickly move back and forth between questions (confirmed on macOS only):
  - Use the `Tab` key plus the arrow keys to select the different radio buttons for the answers, press the `Space bar` to select or deselect one
  - `Ctrl + Option + N` lets you move to the next question, while `Ctrl + Option + P` lets you move back to the previous one

## Recommended learning resources

### Test exams

Here are some test exam courses that I have used and can recommend:

- [Tutorials Dojo (Jon Bonso): AWS Certified Solutions Architect Professional Practice Exams 2023](https://portal.tutorialsdojo.com/courses/aws-certified-solutions-architect-professional-practice-exams/)
  - I took the [Udemy version](https://www.udemy.com/course/aws-solutions-architect-professional-practice-exams-sap-c02/) but I don't like their interface for training mode 1, because you can't easily test and review questions individually.
- [Stephane Marek and Abhishek Singh: Practice Exam AWS Certified Solutions Architect Professional](https://www.udemy.com/course/practice-exam-aws-certified-solutions-architect-professional/)
- [AWS Skillbuilder Exam Prep Official Practice Exam: AWS Certified Solutions Architect - Professional (SAP-C02 - English)](https://explore.skillbuilder.aws/learn/course/external/view/elearning/14048/exam-prep-official-practice-exam-aws-certified-solutions-architect-professional-sap-c02-english)

### Whitepapers/prescriptive guidance

Reading whitepapers/prescriptive guidance can be daunting, but I find them valuable for their insight into the combination and tradeoffs of services that is rarely found elsewhere. Even if you only skim certain parts, I'd encourage you to take a look as it will not only prepare you for the exam, but also introduce you to well-architected solutions and best practices for your own projects.

Here are a few that I recommend:

- [Whitepaper: Building a Scalable and Secure Multi-VPC AWS Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)
  - This outlines several options for connecting VPCs: Peering, Transit Gateway, Transit VPC, PrivateLink, VPC sharing, Private NAT Gateway
- [Whitepaper: Organizing Your AWS Environment Using Multiple Accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/recommended-ous-and-accounts.html)
  - Overview of best practices around AWS Organizations and recommended OU and account structure
- [AWS Prescriptive Guidance: Guide for AWS large migrations](https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/welcome.html)
  - Covers AWS migration strategies

### Videos

When researching a service/feature, I usually watch an eclectic collection of videos from various sources. But there are a few YouTube channels that stand out to me:

- [AWS Bites](https://www.youtube.com/@AWSBites)
- [AWS Events](https://www.youtube.com/@AWSEventsChannel)
- [Be A Better Dev](https://www.youtube.com/@BeABetterDev)
- [CloudDeepDive](https://www.youtube.com/@clouddeepdive)
- [Cloudonaut](https://www.youtube.com/@cloudonaut)
- [Digital Cloud Training](https://www.youtube.com/@DigitalCloudTraining)
- [Loi Liang Yang](https://www.youtube.com/@LoiLiangYang)
- [Stephane Maarek](https://www.youtube.com/@StephaneMaarek)

### Exam experience

Thanks to [Luciano Mammino](https://loige.co/aws-solution-architect-professional-exam-notes-tips) and [Rafal Wilinski](https://www.rwilinski.me/blog/passing-aws-architect-pro/) for sharing their experiences 🙏. Also check out [r/AWSCertifications](https://www.reddit.com/r/AWSCertifications/) on reddit to connect with other people and their certification journeys.

## Luck is what happens when preparation meets opportunity

Before I close, I want to caution you not to stress yourself too much. Yes, take the time to prepare, yes push yourself and strive for continuous improvement, but don't forget that there is always an element of luck involved. The sheer breadth of topics covered can sometimes work against you. Don't get discouraged and don't give up. I learn the most when I'm failing.