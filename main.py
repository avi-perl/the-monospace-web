import shutil
from pathlib import Path

import markdown
import frontmatter
from jinja2 import Environment, FileSystemLoader

# Configuration
TEMPLATE_DIR = "templates"  # Directory containing the Jinja2 template
TEMPLATE_NAME = "template.html"  # Name of the Jinja2 template
INPUT_MD_FILE = "pages/index.md"  # Input Markdown file
OUTPUT_HTML_FILE = "output.html"  # Output HTML file


def load_markdown_file(md_file: Path):
    """Reads the Markdown file, parses front matter, and converts the body to HTML with TOC."""
    # Load Markdown file with front matter
    post = frontmatter.loads(md_file.read_text(encoding='utf-8'))

    # Set up Markdown extensions
    md = markdown.Markdown(extensions=["fenced_code", "tables", "toc"])

    # Convert Markdown content to HTML
    body_content = md.convert(post.content)

    # Extract the generated TOC
    toc_content = md.toc

    # Return front matter, body, and TOC
    return post.metadata, body_content, toc_content


def render_template(template_dir, template_name, context):
    """Renders the Jinja2 template with the given context."""
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template(template_name)
    return template.render(context)


def render_md(file: Path, target_path: Path):
    # Extract front matter, body content, and TOC
    front_matter, body_content, toc_content = load_markdown_file(file)

    # Define the context for the Jinja2 template
    context = {
        "lang": "en",
        "dir": None,
        "body": body_content,
        "css": ["reset.css", "index.css"],
        "toc": True,
        "table_of_contents": toc_content,
        **front_matter  # Merge YAML front matter into the context
    }

    # Render the template
    html_output = render_template(TEMPLATE_DIR, TEMPLATE_NAME, context)

    # Write the output to an HTML file
    target_path.write_text(html_output, encoding="utf-8")
    # with open(OUTPUT_HTML_FILE, "w", encoding="utf-8") as f:
    #     f.write(html_output)
    print(f"HTML file generated: {target_path}")


def main():
    source_dir = Path("pages")
    build_dir = Path("build")
    templates_dir = Path("templates")

    # Ensure the target directory exists
    build_dir.mkdir(parents=True, exist_ok=True)

    # Copy all non-.html files from the templates directory to the build directory
    for template_file in templates_dir.rglob("*"):
        if template_file.is_file() and template_file.suffix != ".html":
            relative_path = template_file.relative_to(templates_dir)
            target_path = build_dir / relative_path
            target_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(template_file, target_path)

    # Loop through all files in the source directory and its subfolders
    for file_path in source_dir.rglob("*"):
        relative_path = file_path.relative_to(source_dir)
        target_path = build_dir / relative_path

        if file_path.is_file():
            target_path.parent.mkdir(parents=True, exist_ok=True)
            if file_path.suffix == ".md":
                render_md(file_path, target_path.with_suffix(".html"))
            else:
                shutil.copy2(file_path, target_path)


if __name__ == "__main__":
    main()
