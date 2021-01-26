Feature: Rules

  Scenario: Basic test case
    When I test "basic"
    Then the output should contain exactly:
      """
      fail.md:3:7:Openly.Terminology:Prefer 'Openly' over 'Openly'
      fail.md:3:19:Openly.Hyperbolic:Consider removing 'just'
      fail.md:3:36:Openly.Spelling:Did you really mean 'eg'?
      fail.md:3:36:Openly.Abbreviations:Use 'e.g.,' instead of 'eg'
      fail.md:3:42:Openly.Spelling:Did you really mean 'ie'?
      fail.md:3:42:Openly.Abbreviations:Use 'i.e.,' instead of 'ie'
      fail.md:5:17:Openly.Spelling:Did you really mean 'spulling'?
      """
