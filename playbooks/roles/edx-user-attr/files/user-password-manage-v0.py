#!/usr/bin/env python
"""
Usage: user-password-manage.py lms [--settings env] ...

"""

# Patch the xml libs before anything else.
from safe_lxml import defuse_xml_libs
defuse_xml_libs()

import os
import sys
import importlib
from argparse import ArgumentParser
import contracts


def parse_args():
    """Parse edx specific arguments to manage.py"""
    parser = ArgumentParser()
    subparsers = parser.add_subparsers(title='system', description='edX service to run')

    lms = subparsers.add_parser(
        'lms',
        help='Learning Management System',
        add_help=False,
        usage='%(prog)s [options] ...'
    )
    lms.add_argument('-h', '--help', action='store_true', help='show this help message and exit')
    lms.add_argument(
        '--settings',
        help="Which django settings module to use under lms.envs. If not provided, the DJANGO_SETTINGS_MODULE "
             "environment variable will be used if it is set, otherwise it will default to lms.envs.dev")
    lms.add_argument(
        '--service-variant',
        choices=['lms'],
        default='lms',
        help='Which service variant to run, when using the aws environment')
    lms.add_argument(
        '--username',
        help='username')
    lms.add_argument(
        '--email',
        help='email')
    lms.add_argument(
        '--password',
        help='password')
    lms.add_argument(
        '--is_staff',
        help='is_staff')
    lms.add_argument(
        '--is_superuser',
        help='is_superuser')
    lms.add_argument(
        '--is_active',
        help='is_active')
    lms.add_argument(
        '--contracts',
        action='store_true',
        default=False,
        help='Turn on pycontracts for local development')
    lms.set_defaults(
        help_string=lms.format_help(),
        settings_base='lms/envs',
        default_settings='lms.envs.aws',
        startup='lms.startup',
    )

    edx_args, django_args = parser.parse_known_args()

    if edx_args.help:
        print "edX:"
        print edx_args.help_string

    return edx_args, django_args


if __name__ == "__main__":
    edx_args, django_args = parse_args()

    if edx_args.settings:
        os.environ["DJANGO_SETTINGS_MODULE"] = edx_args.settings_base.replace('/', '.') + "." + edx_args.settings
    else:
        os.environ.setdefault("DJANGO_SETTINGS_MODULE", edx_args.default_settings)

    os.environ.setdefault("SERVICE_VARIANT", edx_args.service_variant)

    enable_contracts = os.environ.get('ENABLE_CONTRACTS', False)
    # can override with '--contracts' argument
    if not enable_contracts and not edx_args.contracts:
        contracts.disable_all()

    if edx_args.help:
        print "Django:"
        # This will trigger django-admin.py to print out its help
        django_args.append('--help')

    startup = importlib.import_module(edx_args.startup)
    startup.run()

    from django.contrib.auth.models import make_password
    hash = make_password(edx_args.password)

    edx_platform_path=path=os.path.dirname(os.path.abspath(__file__))
    python_bin = "{path}/../venvs/edxapp/bin/python".format(path=edx_platform_path)
    manage_py = "{path}/manage.py".format(path=edx_platform_path)

    command_list= (
        ['''update edxapp.auth_user set
            is_staff={is_staff},
            is_superuser={is_superuser},
            is_active={is_active},
            password="{hashed_password}"
            where username="{username}" and email="{email}";'''
        .format(
            hashed_password=hash,
            username=edx_args.username,
            email=edx_args.email,
            is_staff=edx_args.is_staff,
            is_superuser=edx_args.is_superuser,
            is_active=edx_args.is_active
        )]
    )

    for cmd in command_list:
        current_cmd = (
            "echo '{sql_seq}' | {bin} {manage_script} {service_variant} --settings={settings} dbshell"
            .format(sql_seq=cmd, bin=python_bin, manage_script=manage_py, service_variant=edx_args.service_variant, settings=edx_args.settings)
        )
        print(current_cmd)
        os.system(current_cmd)

