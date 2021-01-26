Feature: Rules

  Scenario: Basic test case
    When I test "basic"
    Then the output should contain exactly:
      """
      fail.md:3:1:Openly.So:Don't start a sentence with 'So,'
      fail.md:3:5:Openly.A11Y:Consider using ''select'' instead of 'click'
      fail.md:3:38:Openly.Anthropomorphism:Don't attribute human qualities to software or hardware.
      fail.md:3:59:Openly.FutureTense:Possible future tense.
      fail.md:3:80:Openly.So:Don't start a sentence with 'so '
      fail.md:3:83:Openly.Hyphens:Use 'right-click' instead of 'right click'
      fail.md:3:89:Openly.A11Y:Consider using ''select'' instead of 'click'
      fail.md:5:1:Openly.But:Do not start a paragraph with a 'but'.
      fail.md:5:5:Openly.E-Prime:Avoid using "I'm"
      fail.md:5:50:Openly.GenderBias:Consider using 'human resources' instead of 'manpower'
      fail.md:5:73:Openly.Hedging:Consider removing 'arguably'
      fail.md:7:22:Openly.Link:Don't use 'here' as the content of a link.
      fail.md:9:9:Openly.Punctuation:Use 'eg, or ie,' instead of 'eg?'
      fail.md:9:9:Openly.Spelling:Did you really mean 'eg'?
      fail.md:9:53:Openly.Punctuation:Use 'eg, or ie,' instead of 'egg'
      fail.md:9:78:Openly.Quotes:Punctuation should be inside the quotes.
      fail.md:9:79:Openly.Spelling:Did you really mean 'american'?
      fail.md:9:163:Openly.QuoteType:Inconsistent use of '”' ('smart' mixed with 'dumb')
      fail.md:11:1:Openly.SentenceLength:Write short sentences (less than 25 words).
      fail.md:13:12:Openly.Spelling:Did you really mean 'spulling'?
      pass.md:3:1:Openly.A11Y:Consider using ''select'' instead of 'Click'
      pass.md:3:34:Openly.Anthropomorphism:Don't attribute human qualities to software or hardware.
      pass.md:3:61:Openly.So:Don't start a sentence with 'so '
      pass.md:3:68:Openly.Hyphens:Use 'right-click' instead of 'right click'
      pass.md:3:74:Openly.A11Y:Consider using ''select'' instead of 'click'
      pass.md:5:1:Openly.But:Do not start a paragraph with a 'but'.
      pass.md:5:5:Openly.E-Prime:Avoid using "I'm"
      pass.md:5:50:Openly.GenderBias:Consider using 'human resources' instead of 'manpower'
      pass.md:5:73:Openly.Hedging:Consider removing 'arguably'
      pass.md:9:9:Openly.Punctuation:Use 'eg' instead of 'e.g.'
      pass.md:9:55:Openly.Punctuation:Use 'eg, or ie,' instead of 'egg'
      real.md:4:4:Openly.E-Prime:Avoid using "you're"
      real.md:4:19:Openly.Spelling:Did you really mean 'javascript'?
      """
