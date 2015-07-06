@filter
Feature: Filter
  As a user of the teelogger gem
  When I use the Filter class
  I expect it to work as documented.

  @filter_01
  Scenario Outline: Replace patterns in Strings
    Given I create a TeeLogger for testing filters
    And I write a log message containing the word "<word>"
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | word           | condition   |
      | hello          | contain     |
      | hello=123      | contain     |
      | --hello=123    | contain     |
      | hello: 123     | contain     |
      | password=123   | not contain |
      | password: 123  | not contain |
      | --password=123 | not contain |

  @filter_02
  Scenario Outline: Replace patterns in Strings in Arrays
    Given I create a TeeLogger for testing filters
    And I write a log message containing the word "<word>" in an Array
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | word           | condition   |
      | hello          | contain     |
      | hello=123      | contain     |
      | --hello=123    | contain     |
      | hello: 123     | contain     |
      | password=123   | not contain |
      | password: 123  | not contain |
      | --password=123 | not contain |

  @filter_03
  Scenario Outline: Replace patterns in Strings in Hashes
    Given I create a TeeLogger for testing filters
    And I write a log message containing the value "<word>" for the key "<key>" in a Hash
    Then I expect the log message to <condition> the word "<word>"

    Examples:
      | key      | word         | condition   |
      | hello    | MUST REMAIN  | contain     |
      | password | TO BE HIDDEN | not contain |

# TODO use own filter words
# TODO use custom filter
