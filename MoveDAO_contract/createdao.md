Simple Explanation of the DAO Core Module
    This code creates a basic DAO (Decentralized Autonomous Organization) system with governance features. Here's what it does in simple terms:

    What's a DAO?
    A DAO is like a digital club where members make decisions together. This code sets up the basic structure for one.

    Main Components:
    DAO Structure: Stores information about each DAO including:
    1. Owner (creator)
    2. Name, logo, and background image
    3. Council members (decision-makers)
    4. Admins (managers)
    5. Proposal counter (tracks how many decisions have been proposed)

    Rules:

    Maximum 10 council members (can't have more)
    The person who creates the DAO automatically becomes its first admin

    What You Can Do:
    Create a DAO:

    Anyone can make one by providing a name, images, and initial council members
    The creator automatically becomes an admin

    Check Permissions:
    See if someone is an admin
    See if someone is on the council

    Get DAO Info:

    View all details about any DAO

    Safety Features:
    i. Limits council size to prevent too many decision-makers
    ii. Makes sure only valid addresses are used

Simple Example:
Imagine creating a "Neighborhood Book Club" DAO:
You (creator) are the first admin
You pick 5 friends as council members
The DAO stores your club name, logo, and background image
You can see who's an admin or council member
You can track how many book choices have been proposed

This is just the core - you'd add more features for actual voting and proposals.
    PS C:\Users\josep\Desktop\MoveDAO_back>  aptos move test --named-addresses dao_core=default --skip-fetch-latest-git-deps
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING MoveDAO_v2
Running Move unit tests
[ PASS    ] 0x160c30b861d6e3ac4864903423e6523a2ed873ae1b41132382f699b07ac684ec::dao_core_tests::test_constants_through_helpers
[ PASS    ] 0x160c30b861d6e3ac4864903423e6523a2ed873ae1b41132382f699b07ac684ec::dao_core_tests::test_council_size_limit
[ PASS    ] 0x160c30b861d6e3ac4864903423e6523a2ed873ae1b41132382f699b07ac684ec::dao_core_tests::test_dao_creation
[ PASS    ] 0x160c30b861d6e3ac4864903423e6523a2ed873ae1b41132382f699b07ac684ec::dao_core_tests::test_get_dao_info
[ PASS    ] 0x160c30b861d6e3ac4864903423e6523a2ed873ae1b41132382f699b07ac684ec::dao_core_tests::test_permission_checks
Test result: OK. Total tests: 5; passed: 5; failed: 0
{
  "Result": "Success"
}