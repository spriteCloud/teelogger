@logger
Feature: Logger
  As a user of the teelogger gem
  When I use the TeeLogger class
  I expect it to work as documented.

  @logger_01
  Scenario Outline: Default parameters
    Given I create a TeeLogger with default parameters
    And I set the log level to "<level>"
    And I write a log message at log level "<level>"
    Then I expect the log level "<level>" to have taken hold
    And I expect the log message to appear on the screen

    Examples:
      | level |
      | DEBUG |
      | INFO  |
      | WARN  |
      | ERROR |
      | FATAL |

  @logger_02
  Scenario Outline: I/O object
    Given I create a TeeLogger with an IO object
    And I set the log level to "<level>"
    And I write a log message at log level "<level>"
    Then I expect the log level "<level>" to have taken hold
    And I <expectation> the log message to appear in the IO object

    Examples:
      | level | expectation  |
      | DEBUG | expect       |
      | INFO  | expect       |
      | WARN  | don't expect |
      | ERROR | expect       |
      | FATAL | expect       |

  @logger_03
  Scenario: multiple loggers
    Given I create a TeeLogger with multiple loggers
    Then I expect the class to let me access all loggers like a hash
