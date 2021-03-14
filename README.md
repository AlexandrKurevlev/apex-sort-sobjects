apex-sort-sobjects
=================

Utility class for sorting SObjects by a field or multiple fields with primitive data types.

Notes
-----

It doesn't allow sorting by Address or Location fields, but it is possible to explicitly sort by its components: Country or City and Latitude or Longitude.

String values compared lexicographically, based on the Unicode value of each character in the Strings.

Example usage
-------------

```apex
List<Contact> sortedContacts = new SortSObjects() 
    .ascending(Contact.FirstName)
    .ascending(Contact.LastName)
    .sort(contacts);
```