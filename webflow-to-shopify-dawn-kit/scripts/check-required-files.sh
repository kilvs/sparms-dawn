#!/usr/bin/env bash
# Pre-push verifier — confirms Shopify's required theme files exist.
#
# In the Dawn variant of the kit, the commerce templates
# (templates/product.json, collection.json, cart.json, search.json,
# templates/customers/*.liquid) are supplied by merge-dawn-commerce.{sh,ps1}.
# If this script reports them MISSING, run convert-all (or the merge step
# directly) before pushing.
#
# Run from your theme root:
#   bash webflow-to-shopify-dawn-kit/scripts/check-required-files.sh
#
# Outputs MISSING: <path> for each absent file. Empty output = all present.
# Exits with code 1 if anything is missing, 0 otherwise.

set -e
missing=0

# Files that must exist at an exact path.
REQUIRED=(
  layout/theme.liquid
  layout/password.liquid
  templates/index.json
  templates/product.json
  templates/collection.json
  templates/list-collections.json
  templates/page.json
  templates/blog.json
  templates/article.json
  templates/search.json
  templates/cart.json
  templates/404.json
  templates/password.json
  templates/gift_card.liquid
  config/settings_schema.json
  config/settings_data.json
  locales/en.default.json
)

# Files Shopify accepts as either .json (sections-based) or .liquid (legacy).
# Modern Dawn ships these as .json — accept that as a valid form.
REQUIRED_EITHER=(
  templates/customers/account
  templates/customers/activate_account
  templates/customers/addresses
  templates/customers/login
  templates/customers/order
  templates/customers/register
  templates/customers/reset_password
)

for f in "${REQUIRED[@]}"; do
  if [ ! -e "$f" ]; then
    echo "MISSING: $f"
    missing=$((missing + 1))
  fi
done

for stem in "${REQUIRED_EITHER[@]}"; do
  if [ ! -e "$stem.json" ] && [ ! -e "$stem.liquid" ]; then
    echo "MISSING: $stem.json or $stem.liquid"
    missing=$((missing + 1))
  fi
done

if [ $missing -eq 0 ]; then
  echo "All required files present."
  exit 0
else
  echo ""
  echo "$missing required file(s) missing. Theme will not pass publish-time validation."
  exit 1
fi
