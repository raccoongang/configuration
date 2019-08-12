Configuration Pull Request
---

Make sure that the following steps are done before merging

  - [ ] @devops team member has commented with :+1:
  - [ ] are you adding any new default values that need to be overridden when this goes live?  
    - [ ] Open a ticket (DEVOPS) to make sure that they have been added to secure vars.
    - [ ] Add an entry to the CHANGELOG.
- [ ] Have you performed the proper testing specified on the [Ops Ansible Testing Checklist](https://openedx.atlassian.net/wiki/display/EdxOps/Ops+Ansible+Testing+Checklist)?

If changes are made as part of the base installation, then you need to issue a pull requests to all the basic branches:
- [ ] ficus-rg
- [ ] gingko-rg
- [ ] hawthorn-rg
- [ ] development gingko-rg
- [ ] development hawthorn-rg
