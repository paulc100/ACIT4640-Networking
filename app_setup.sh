#!/bin/bash

scp -r setup todoapp:
ssh todoapp bash setup/install_script.sh