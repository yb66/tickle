# CH CH CH CH CHANGES! #

## Friday the 18th of September 2020, v1.2.0

- Changed the dependency from chronic to gitlab-chronic
- Required numerizer explicitly to stop a bug
- Formatted the regex for legibility
- Fixed bug with "today and" in the tests
- Fixed a bug previously fixed on the v2 branch in 2f2a32ce9 with @start
- Added Timecop because we're beyond the date chosen in the tests. Tempus fugit!

----

## Wednesday the 22nd of February 2017, v1.1.0 ##

* Numerizer duplication removed. Thanks to https://github.com/bjonord.
* Some very minor changes to the project, no other code changes.

----


## Monday the 11th of November 2015, v1.0.2 ##

* Shoulda and simplecov aren't runtime dependencies, fixed that in the gemfile.
* Got the version number right this time ;-)

----

## Monday the 11th of November 2015, v1.0.1 ##

* Moved library to new maintainer [https://github.com/yb66/tickle](@yb66)
* Moved library to [http://semver.org/](semver).
* Merged in some changes from @dan335 and @JesseAldridge, thanks to them.
* Moved rdocs to markdown for niceness.
* Updated licences with dates and correct spelling ;)
* Fix incorporated for "NameError: uninitialized constant Module::Numerizer"
* Moved library to Bundler to make it easier to set up and develop against.
* Started using Yardoc for more niceness with documentation.

----