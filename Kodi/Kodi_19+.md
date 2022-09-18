# Kodi 19+

##  Kodi 19 (Matrix) and newer: Python 3

Starting from Kodi 19 (Matrix), Python 3 is used.

This means that older add-ons will have to be updated to continue working.

For more information including tools for converting code such as `futurize`, see https://kodi.wiki/view/General_information_about_migration_to_Python_3

## Kodi 20 (Nexus): `<dir>` tags for repositories

As of September 2022, many repositories cannot be used with Kodi 20, and trying to use them leads to the following error message in `/storage/.kodi/temp/kodi.log`:

`ERROR <general>: Repository add-on repository.<...> does not have any directory and won't be able to update/serve addons! Please fix the addon.xml definition` and `ERROR <general>: Repository add-on repository.<...> uses old schema definition for the repository extension point! This is no longer supported, please update your addon to use <dir> definitions.`

Repository owners need to fix it by adding `<dir>` tags:

```
<extension point="xbmc.addon.repository" name="PlexKodiConnect Repository Kodi 19 Matrix">
	<dir>
		<info compressed="false">https://raw.githubusercontent.com/croneter/binary_repo/master/stable_py3/addons.xml</info>
		<checksum>https://raw.githubusercontent.com/croneter/binary_repo/master/stable_py3/addons.xml.md5</checksum>
		<datadir zip="true">https://raw.githubusercontent.com/croneter/binary_repo/master/stable_py3/</datadir>
	</dir>
</extension>
```
