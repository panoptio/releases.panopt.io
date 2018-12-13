# releases.panopt.io

Repo for managing the distributable binary S3 bucket `s3://releases.panopt.io`.

## Creating HTML Markup for a specific product


* The generic `product.yml` playbook will prompt for a product name.
* The products are defined in `vars/releases.yml`.
* HTML is dynamically generated for the selected product and each version that exists.
* It will then upload the generated html documents upload to S3.

It is the easiest way to do everything **APART** from uploading the actual distributable binary.

Example:
```
ansible-playbook product.yml

Enter Product (flitter|shots) [flitter]: shots 

```

That will use your localhost to generate templated HTML markup for every Product release in `vars/releases.yml` and upload those files to S3 and make them public. Being your local host, there are some pre-requirements:
- `awscli`
- Proper default access keys in your `~/.aws/credentials` file

---

TODO:
- better documentation