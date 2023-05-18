import React from "react";
import { Link, graphql } from "gatsby";
import Helmet from "react-helmet";

import Bio from "../components/Bio";
import Layout from "../components/layout";
import { rhythm } from "../utils/typography";

export const Head = () => (
  <>
    <html lang="en" />
    <link href="https://mastodon.social/@paulgalow" rel="me" />
  </>
);

class BlogIndex extends React.Component {
  render() {
    const siteTitle = this.props.data?.site?.siteMetadata?.title;
    const siteDescription = this.props.data?.site?.siteMetadata?.description;
    const posts = this.props.data?.allMarkdownRemark?.edges;

    return (
      <Layout location={this.props.location}>
        <Helmet
          htmlAttributes={{ lang: "en" }}
          meta={[
            { name: "description", content: siteDescription },
            { name: "referrer", content: "no-referrer" },
          ]}
          title={siteTitle}
        />
        <Bio />
        {posts.map(({ node }) => {
          const title = node.frontmatter?.title || node.frontmatter?.slug;
          return (
            <div key={node.frontmatter.slug}>
              <h3
                style={{
                  marginBottom: rhythm(1 / 4),
                }}
              >
                <Link style={{ boxShadow: "none" }} to={node.frontmatter.slug}>
                  {title}
                </Link>
              </h3>
              <small>{node.frontmatter.date}</small>
              <p dangerouslySetInnerHTML={{ __html: node.excerpt }} />
            </div>
          );
        })}
      </Layout>
    );
  }
}

export default BlogIndex;

export const pageQuery = graphql`
  query {
    site {
      siteMetadata {
        title
        description
      }
    }
    allMarkdownRemark(sort: { frontmatter: { date: DESC } }) {
      edges {
        node {
          excerpt
          frontmatter {
            date(formatString: "DD MMMM, YYYY")
            title
            slug
          }
        }
      }
    }
  }
`;
