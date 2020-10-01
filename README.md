# Encrypted Data Bag Repo

_Make sure you follow the [this guide](https://github.com/chef-cft/chef-examples/blob/master/examples/ChefTestKitchenEncryptedDataBags.md)
to get setup with local encrypted data bags before using this._

**This repo is a template** that can be used to:
* Ensure all data bags are encrypted prior to being committed to SCM.
* Automate the locking (for commit) and unlocking (for editing) of data bags in
a secure manner.
* Provide a sane, repeatable pattern for teams using encrypted data bags.

## Create Data Bags
1. Clone this repo locally, copy it into your own repo.
1. Copy your encrypted data bag secret into the `secrets/` directory and name it
something unique, for example, if the app is `ymir` call it `ymir_secret` or 
something similar, try to avoid calling it the same across data bag repos 
because we can pull these keys in during Test Kitchen runs and if they have
unique names it makes life easier.
1. Create your data bags in the `data_bags` directory, you can use the
examples as a guide, basically it's `data_bags\bagName\bagItem-open.json`, be sure to end them in `-open.json` because this is the pattern that is 
looked for when running the encrypt script.

## Encrypt Data Bags for Committing
1. Run the `scripts/dbag-ops.sh -l -s <secret file path> [ -p <bagName> ]` which will encrypt each data bag in the 
`data_bags` path into it's own new file removing `-open.json`. You can specify a pattern with `-p *bagname*` if you want to limit the scope of the operation, example:
    ```
    # Lock all data bags in the `data_bags` path:
    ./dbag-ops.sh -l -s ../secrets/my_super_secret

    # Lock specific data bags in the `data_bags` path:
    ./dbag-ops.sh -l -s ../secrets/my_super_secret -p ymir-api
    ```
1. When finished editing, run `scripts/lock.sh` to encrypt all `*-open.json` 
files (overwriting the original), and then delete them.

## Decrypt Data Bags for Editing
1. Run the `scripts/dbag-ops.sh -u -s <secret file path> [ -p <bagName> ]` which will decrypt each data bag in the 
`data_bags` path into it's own new file, appending `-open.json`. You can specify a data bag name with `-p bagname` if you want to limit the scope of the operation, example:
    ```
    # Lock all data bags in the `data_bags` path:
    ./dbag-ops.sh -l -s ../secrets/my_super_secret

    # Lock a specific data bag in the `data_bags` path:
    ./dbag-ops.sh -l -s ../secrets/my_super_secret -p ymir-api
    ```
1. Don't delete or change the file that was created with `-open.json`, edit this
file directly to change the data bag values, then save it prior to encrypting.

## Automatically Test for non-Encrypted Data Bags Before a Commit
When using GitHub, you can use a `pre-commit` hook to run a script prior to 
allowing a `git commit` operation to continue. To do this, create a file called
`.git/hooks/pre-commit` in the base of the repo, and add the follwing content:
```
#!/bin/bash

for d in data_bags/*/ ; do
  for f in $d* ; do
    if grep -q 'encrypted_data' $f; then
      echo "$f is encrypted [PASS]"
    else
      echo "$f contains non-encrypted data, please run the lock.sh script before committing again [FAIL]"
      exit 1
    fi
  done
done
```

When you run `git commit` you'll see this output if all of your data bags are
encrypted properly:

```
git commit -m "Updating README.md and other things..."
data_bags/ymir-api/attributes.json is encrypted [PASS]
data_bags/ymir-api/regions.json is encrypted [PASS]
data_bags/ymir-backend/attributes.json is encrypted [PASS]
data_bags/ymir-base/attributes.json is encrypted [PASS]
data_bags/ymir-cache/attributes.json is encrypted [PASS]
data_bags/ymir-lb/attributes.json is encrypted [PASS]
data_bags/ymir/attributes.json is encrypted [PASS]
[updating_ymir 4db5999] Updating README.md and other things...
 3 files changed, 46 insertions(+)
 create mode 100755 scripts/lock.sh
 create mode 100755 scripts/pre-commit.sh
 create mode 100644 scripts/unlock.sh
```

By following this guide, you can make sure that your data bags are always 
encrypted prior to being uploaded to SCM.