pragma solidity ^0.4.24;

/*                                                      **********      CONTRACT OVERVIEW       **********
                        
    This contract deploys a voting mechanism which includes various functionalities.
    fucntionality list :
    A. Adding personnel
         1. Adding a voter.
         2. Adding a candidate.
         3. Adding commision officer.
         
    B. Actions
         1. Request to vote.
         2. Vote for a candidate.
         3. Switch legitimacy of any account (can only be done by Commison officer).
*/

contract Election{
    
/*                                                      **********      VOTER       **********

                                    This section of the code is to register a voter and provide their action fucntions.
*/

    uint public voter_index; //used to map array index to address.
    uint public voter_govt_ID;  //index to keep index of voter's govt ID. 
    string govt_ID;     //goverenment verified document number.
            
    enum Voter_State {Active, Inactive} //legitimacy status.
    
    struct voter {
        string name;
        string fathersname;
        string adress;
        string gender;
        string DOB;
        uint constituency;
        address ID;
        bool vote;
        Voter_State Voter_Status;
    }
    
    string [] public govt_ID_list;
    voter [] public voter_list;     //list to store all registered voters.
    
    mapping(address => bool) public reg_voter;      //saves registered account and their address.
    mapping(address => uint) public voter_find;     //saves registered account's index number and their address.
    mapping(address => string) public govt_reg;
    
    //create a function to search the input ID from the pool.
    function findGovtId (/*string memory a*/) public view returns(bool){
        return true;
    }
    
    
    //function to compare two sets of strings, by changing them to hash first and then comapring the hash.
    function compareStrings (string memory a, string memory b) public pure returns (bool) {
            return keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b)));
    }
    
    //function to add the voters.
    function add_Voter(string _name, string _fathersname, string _address, uint _constituency, string _gender, string _DOB) public {
         
         //registered voters can't re-register.
         require(reg_voter[msg.sender] == false);
         
         voter memory NewVoter = voter({
                                              name : _name,
                                              fathersname : _fathersname,
                                              adress : _address,
                                              constituency : _constituency,
                                              gender : _gender,
                                              DOB : _DOB,
                                              ID : msg.sender,
                                              vote : false,
                                              Voter_Status : Voter_State.Active});
         voter_list.push(NewVoter);
         reg_voter[msg.sender] = true;
         voter_find[msg.sender] = voter_index;
         govt_reg[msg.sender] = govt_ID;
         voter_index++; 
         //since array index and int starts with 0, it will be easier to keep tabs by incrementing this with each submission.
    }
    
    //voter request to be allowed to vote.
     function VoteRequest() public {
        require(reg_voter[msg.sender] == true, "error in 2");   //check if the voter is registered.

        //bringing the voter's information from blockchain.
        uint index = voter_find[msg.sender];
        voter storage thisVoter = voter_list[index];
        
        require(thisVoter.vote == false, "error in 3");     //check their voting rights are currently revoked.
        require(thisVoter.Voter_Status == Voter_State.Active, "error in 4"); //chechking the legitimacy of the account.
        
        thisVoter.vote = true;      //invoking voting rights.
    }
    
    //vote for a particular candidate.
    function Vote_Candidate(address _candidateID) public{
        require(reg_candidate[_candidateID] == true);   //check candidate is registered.
        
        //bringing voter's information from blockchain
        uint index = voter_find[msg.sender];
        voter storage thisVoter = voter_list[index];
        
        require(thisVoter.vote == true);    //check their voting rights are invoked.
        
        //bringing information of the candidate the voter selected.
        uint serial = candidate_find[_candidateID];
        candidate storage thisCandidate = candidate_list[serial];
        
        //increasing his voting tally.
        thisCandidate.votes++;
        
        //revoking the voting rights after voter has voted.
        thisVoter.vote = false;
    }
    
/*                                              **********      CANDIDATE       **********

                        This section registers the candidate and provides functions regarding the candidates.
 */  
 
    uint public candidate_index;
    
    enum Candidate_State {Active, Inactive}
    
    struct candidate {
        string name;
        string fathersname;
        string adress;
        uint constituency;
        string gender;
        uint DOB;
        address ID;
        Candidate_State Candidate_Status;
        uint votes;
    }
    
    candidate [] public candidate_list;
    
    mapping(address => uint) public candidate_find;
    mapping(address => bool) public reg_candidate;
    
    function add_Candiadte(string _name, string _fathersname, string _address, uint _constituency, string _gender, uint _DOB) public {
         candidate memory Newcitizen = candidate({
                                              name : _name,
                                              fathersname : _fathersname,
                                              adress : _address,
                                              constituency : _constituency,
                                              gender : _gender,
                                              DOB : _DOB,
                                              ID : msg.sender,
                                              votes : 0,
                                              Candidate_Status : Candidate_State.Active});
         candidate_list.push(Newcitizen);
         reg_candidate[msg.sender] = true;
         candidate_find[msg.sender] = candidate_index;
         candidate_index++;
    }
    
    
/*                                              **********      COMMISION OFFICER       **********
                    
                            This section deals with registering the commision officers and their respective functions.
*/

    uint public officer_index;
    
    struct Officer{
        string ID;
        string name;
    }
    
    Officer [] internal Officer_list;
    mapping(address => bool) reg_officer;
    mapping(address => uint) officer_find;
    
    function add_Officer(string _name, string _ID) public{
        Officer memory NewOfficer = Officer({
                                                name : _name,
                                                ID : _ID
                                    });
        Officer_list.push(NewOfficer);
        reg_officer[msg.sender] = true;
        officer_find[msg.sender] = officer_index;
        officer_index++;
    }
    
    function changeStatus(address ID) public {
       require(reg_officer[msg.sender] == true, "error in 1");

       uint index = voter_find[ID];
       voter storage thisCitizen = voter_list[index];
       
       thisCitizen.Voter_Status = Voter_State.Inactive;
    }
}