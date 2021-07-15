# dataworks-githooks
Repo for holding DataWorks Git hooks

### Premise

_*post-checkout :*_  
This is designed to update the .githooks submodule (this repo), whever there is a checkout action. If this is deemed too aggressive, we can look to adjust to something else.

_*pre-commit :*_  
This is designed to catch any secret/private content being accidently commited to public repositories.  These include AWS Account IDs, Access key IDs, IP addresses, email addresses etc...
This as been adjusted to ignore lines beginning Subproject commit to avoid triggering its own pre-commit check ("40 character random (e.g. AWS secret access key, PAT)"). It also checks for the initial-commit script existing in the repo root, and will block commits if it does. This is to double check users are running make initial-commit after creating a new repo.