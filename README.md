## UIMP Example App

__Universal Identity Management Protocol__ (UIMP) is a set of APIs that UniAuth-compliant services should support. UniAuth clients manage users' identities stored in the service through the APIs. Currently, this version of UIMP is designed as a set of RESTful APIs for web services.

UIMP is designed to enable password management applications to handle account management tasks with minimum user intervention. This API will also be ported to other small local devices through Bluetooth or NFC.

####This Rails application is as an example of how this service could be implemented into an existing web app. This can also serve as the basis for extraction into a Rails gem for future use.####

_Note: There is almost no front-end interface. Interaction with this app is meant to go through API calls._