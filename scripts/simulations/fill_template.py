#!/usr/bin/env python
import argparse
import os

import jinja2


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("template")
    parser.add_argument("FV3CONFIG_REFERENCE_DIR")
    parser.add_argument("ML_MODELS")
    parser.add_argument("PRESCRIBER_DATASETS")
    parser.add_argument("RESTARTS_ROOT")
    parser.add_argument("destination")
    args = parser.parse_args()

    template_dir, template_file = os.path.split(args.template)
    template_loader = jinja2.FileSystemLoader(searchpath=template_dir)
    template_env = jinja2.Environment(loader=template_loader, autoescape=True)
    template = template_env.get_template(template_file)

    result = template.render(
        FV3CONFIG_REFERENCE_DIR=args.FV3CONFIG_REFERENCE_DIR,
        ML_MODELS=args.ML_MODELS,
        PRESCRIBER_DATASETS=args.PRESCRIBER_DATASETS,
        RESTARTS_ROOT=args.RESTARTS_ROOT
    )

    os.makedirs(os.path.dirname(args.destination), exist_ok=True)
    with open(args.destination, "w") as file:
        file.write(result)
