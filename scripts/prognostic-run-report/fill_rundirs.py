#!/usr/bin/env python
import argparse
import os

import jinja2


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("template")
    parser.add_argument("SIMULATION_ROOT")
    parser.add_argument("destination")
    args = parser.parse_args()

    template_dir, template_file = os.path.split(args.template)
    template_loader = jinja2.FileSystemLoader(searchpath=template_dir)
    template_env = jinja2.Environment(loader=template_loader, autoescape=True)
    template = template_env.get_template(template_file)

    result = template.render(SIMULATION_ROOT=args.SIMULATION_ROOT)

    os.makedirs(os.path.dirname(args.destination), exist_ok=True)
    with open(args.destination, "w") as file:
        file.write(result)
