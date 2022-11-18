#!/bin/bash

set -euo pipefail

echo "##[section]Setting up Python environment..."
conda create -n dev -y -q -c conda-forge python=3.9 numpy scipy pandas pytest scikit-learn awscli \
  xgboost lightgbm
source activate dev

echo "##[section]Installing Treelite into Python environment..."
pip install wheelhouse/*.whl

echo "##[section]Running Python tests..."
python -m pytest -v -rxXs --fulltrace tests/python/test_basic.py
