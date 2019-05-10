# releases.panopt.io - Ansible Playbook for static website generation

Repo for managing the HTML and resources (distributable binaries) S3 bucket `s3://releases.panopt.io`.

## Creating HTML Markup for a specific product

* The generic `product.yml` playbook will prompt for a product name.
* The products are defined in `vars/releases.yml`.
* HTML is dynamically generated for the selected product and each version that exists.
* It will then upload the generated html documents upload to S3.

It is the easiest way to do everything **APART** from uploading the actual distributable binary (see below...).

Example:
```
ansible-playbook product.yml

Enter Product (flitter|slainte) [slainte]: slainte 

```

That will use your localhost to generate templated HTML markup for every Product release in `vars/releases.yml` and upload those files to S3 and make them public. Being your local host, there are some pre-requirements:
- `awscli`
- Proper default access keys in your `~/.aws/credentials` file

---

## Downloading binary artifacts (builds) to publish to the releases bucket.

A playbook called `distribute_artifact.yml` will take a series of arguments (will be prompted if not passed via `--extra-vars` on the CLI)

* `product`: The friendly name of the product we're releasing.  This will define both the artifact we're downloading as well as be used to build the target path in the `target_bucket` defined below.
By Default: <target_bucket>/<product>
* `version`: The version of the binary artifact we're distributing.
* `source`: The base URL for where out protected artifact is stored
Example: https://artifactory.domain.com/repository/apps/
* `extension`: The file extension we're dealing with.  Appropriate actions are taken within the playbook based on this file extension.  This is also used to build both the source download URI and target URI
* `auth_required`: This needs to be set to `True` if your artifact repository requires authorization (**it should...**).  
* `target_bucket`: This playbook assumes we're distributing our binaries to an S3 bucket, so this is the bucket name we want to send it to.

All of the above will generate two items:

* `download_uri`: `<source>/<product>/<version>/<product>.<extension>`
* `target_uri`: `<target_bucket>/<product>/<version>/<product>[_<version>].<extension>`

#### Executing:

There are a couple of options to execute this playbook.  If you simply execute from the CLI, the following should work for you:

```bash
ansible-playbook distribute_artifact.yml --ask-vault-pass
# The latter option is only necessary if you choose True (default) when prompted for auth_required.
```

This will prompt you to fill in all of the above arguments to complete execution of the playbook.

##### For use with CI/CD...

* In the `<repo_root>/ansible/` directory, create a file called `.vault_pass.txt` and add your vaulted vars file password into it.
* We will define all of the arguments on the cli using the `--extra-vars` argument for ansible.  It should look something like the following:
```bash
ansible-playbook distribute_artifact.yml --vault-password-file .vault_pass.txt --extra-vars '{
    "product":"slainte",
    "version":"0.9.1",
    "extension": "ipa",
    "source": "http://eclipse:8081/repository/panoptio-apps/app",
    "auth_required": True,
    "target_bucket": "releases.panopt.io"
}'
```

## TODO:
* better documentation
* ~~write playbook for creating resources (manifests, etc..) and uploading distributable binaries to the S3 bucket.~~
  * ~~Document above~~

