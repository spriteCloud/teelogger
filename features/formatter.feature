@formatter
Feature: Formatter
  As a user of the teelogger gem
  When I use the Formatter class
  I expect it to work as documented.

  @formatter_01
  Scenario Outline: Placeholders
    Given I create a Formatter with "{<placeholder>}" in the format string
    And I call it with parameters "<severity>", "<time>", "<progname>" and "<message>"
    Then I expect the result to match "<result>"

    Examples:
      | placeholder           | severity | time                     | progname | message      | result                       |
      | severity              | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | INFO                         |
      | severity              | InfO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | INFO                         |
      | short_severity        | iNFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | I                            |
      | short_severity        | infO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | I                            |
      | logger_timestamp      | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57.000000   |
      | logger_timestamp      | InfO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57.000000   |
      | logger_timestamp      | InfO     | 2015-07-03T12:10:57+0100 | STDOUT   | test message | 2015-07-03T11:10:57.000000   |
      | iso8601_timestamp     | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57\\\\+0000 |
      | iso8601_timestamp     | InfO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57\\\\+0000 |
      | iso8601_timestamp     | InfO     | 2015-07-03T12:10:57+0100 | STDOUT   | test message | 2015-07-03T11:10:57\\\\+0000 |
      | iso8601_timestamp_utc | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57Z         |
      | iso8601_timestamp_utc | InfO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | 2015-07-03T12:10:57Z         |
      | iso8601_timestamp_utc | InfO     | 2015-07-03T12:10:57+0100 | STDOUT   | test message | 2015-07-03T11:10:57Z         |
      | tai64n_timestamp      | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | @4000000055967bdb000001f4    |
      | tai64n_timestamp      | InfO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | @4000000055967bdb000001f4    |
      | tai64n_timestamp      | InfO     | 2015-07-03T12:10:57+0100 | STDOUT   | test message | @4000000055966dcb000001f4    |
      | logger                | iNFO     | 2015-07-03T12:10:57Z     | sTDouT   | test message | sTDouT                       |
      | message               | iNFO     | 2015-07-03T12:10:57Z     | STDOUT   | teSt mESsage | teSt mESsage                 |
      | pid                   | iNFO     | 2015-07-03T12:10:57Z     | STDOUT   | teSt mESsage | \\\\d+                       |


      # Note 1: need four \ to escape a special character in the regex field

  @formatter_02
  Scenario Outline: Format strings
    Given I create a Formatter with the "<format>" format string
    And I call it with parameters "<severity>", "<time>", "<progname>" and "<message>"
    Then I expect the result to match "<result>"

    Examples:
      | format         | severity | time                     | progname | message      | result                                                                       |
      | FORMAT_LOGGER  | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | I, \\\\[2015-07-03T12:10:57.000000 #\\\\d+\\\\] INFO -- STDOUT: test message |
      | FORMAT_DEFAULT | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | I, \\\\[2015-07-03T12:10:57\\\\+0000 #\\\\d+\\\\] STDOUT: test message       |
      | FORMAT_SHORT   | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | I, \\\\[2015-07-03T12:10:57\\\\+0000\\\\] test message                       |
      | FORMAT_DJB     | INFO     | 2015-07-03T12:10:57Z     | STDOUT   | test message | @4000000055967bdb000001f4 INFO: test message                                 |
