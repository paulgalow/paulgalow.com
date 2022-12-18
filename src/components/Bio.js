import React from "react";

// Import typefaces
import "typeface-montserrat";
import "typeface-merriweather";

import profilePic from "../assets/profile-pic.jpg";
import gitHubPic from "../assets/github.png";
import twitterPic from "../assets/twitter.png";
import linkedInPic from "../assets/linkedin.png";
import { rhythm } from "../utils/typography";

const gitHubUrl = "https://github.com/paulgalow";
const twitterUrl = "https://twitter.com/paulgalow";
const linkedinUrl = "https://www.linkedin.com/in/paulgalow/";

class Bio extends React.Component {
  render() {
    return (
      <div
        style={{
          display: "flex",
          marginBottom: rhythm(2.5),
        }}
      >
        <img
          src={profilePic}
          alt={`Paul Galow`}
          style={{
            marginRight: rhythm(1 / 2),
            marginBottom: 0,
            width: rhythm(3),
            height: rhythm(3),
          }}
        />
        <p>
          Hi, I'm Paul Galow, and I'm an engineer based in Berlin working in AWS
          with a focus on Serverless. I'm also an IT manager and a Mac admin.
          <br />
          <a href={gitHubUrl} style={{ boxShadow: "none" }}>
            <img
              src={gitHubPic}
              alt={`GitHub`}
              style={{
                marginRight: rhythm(1 / 4),
                marginBottom: 0,
                width: rhythm(1),
                height: rhythm(1),
              }}
            />
          </a>
          <a href={twitterUrl} style={{ boxShadow: "none" }}>
            <img
              src={twitterPic}
              alt={`Twitter`}
              style={{
                marginRight: rhythm(1 / 4),
                marginBottom: 0,
                width: rhythm(1),
                height: rhythm(1),
              }}
            />
          </a>
          <a href={linkedinUrl} style={{ boxShadow: "none" }}>
            <img
              src={linkedInPic}
              alt={`LinkedIn`}
              style={{
                marginRight: rhythm(1 / 4),
                marginBottom: 0,
                width: rhythm(1),
                height: rhythm(1),
              }}
            />
          </a>
        </p>
      </div>
    );
  }
}

export default Bio;
