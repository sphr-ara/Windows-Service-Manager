# Windows Service Manager
### Description:
Windows Service Manager is a tool designed for installing and modifying Windows services effortlessly.


### Instructions:

- Setup:
  - Download `ServiceManager.bat` and place it in your desired directory.

- Installation:
  - Drag and drop your bin file onto `ServiceManager.bat`.
  - Grant administrative access when prompted[^1].
  - Choose a name for your service.
  - Confirm your service name by entering 'y'.
  - IF you want to set description for your installed service enter 'y'.

- Uninstallation:
  - Double-click on `ServiceManager.bat`.
  - Grant administrative access when prompted[^1].
  - Select the service you wish to uninstall from the list.
    - (If your service is not listed, add its name to `service_list.txt` in the directory of `ServiceManager.bat`)
  - Confirm your choice by entering 'y'.
  - Choose uninstall from action menu by entering 1.
  - Confirm uninstall by entering 'y'.

- Set description:
  - Double-click on `ServiceManager.bat`.
  - Grant administrative access when prompted[^1].
  - Select the service you wish to set description for from the list.
    - (If your service is not listed, add its name to `service_list.txt` in the directory of `ServiceManager.bat`)
  - Confirm your choice by entering 'y'.
  - Choose set description from action menu by entering 2.
  - Write your desired description for chosen service.
  - Confirm your description by entering 'y'.

> [!IMPORTANT]
> For any operations requiring administrative access, ensure you approve the request when prompted.


[^1]: [Request Admin Privileges source code](https://github.com/techno-world/Command-Prompt/blob/master/Request%20Admin%20Privileges.bat)
