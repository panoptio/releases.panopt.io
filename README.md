# releases.panopt.io

This repo provides the necessary resources to generate a simple website linking to distributable binaries.  For example, if you are building mobile application, or publicly distributing your SDK's, the tools in this repo will do the following:

* Create AWS Infrastructure for hosting the static website via [terraform](https://www.terraform.io/)
* Automatically generate static HTML and upload it to the AWS S3 bucket hosting the website via [ansible](https://www.ansible.com/)

## Modules

__Note:__ Execute modules in the documented order below:

* [terraform](terraform/README.md): Infrastructure code to setup AWS resources for hosting a static website with CDN and TLS
* [ansible](ansible/README.md): Ansible code for generating the static html resources and uploading them to the AWS hosted website.

## Credits / Inspiration:

Up until I started [Panopt.io](https://www.panopt.io), I worked with the best DevOps/SRE team in the land.  These guys introduced me to so many new ideas, and I can't thank them enough.  This ansible piece of this toolset was originally started on that team, and We always had a backlog story to make it "generic" enough, as well as create the infra behind the site.  I am fortunate, that story made it into my Panopt.io backlog so I could finish it!

In no particular order, I want to thank the following members of the best DevOps team in the land!

- [@dailyherold](https://github.com/dailyherold)
- [@onemorepereira](https://github.com/onemorepereira)
- [@TNExamsoft](https://github.com/TNExamsoft)

