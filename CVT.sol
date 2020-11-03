//Author: Yuexin Xiang
//E-mail: yuexin.xiang@cug.edu.cn

//Remix: Compiler 0.4.24+conmmit.e67f0147

pragma solidity >=0.4.22 <0.7.0;

contract CVT{
    //bidding basic settings
    address public Employer;
    address public SuccessfulBidder;
    uint BidStartTime;
    uint public BidTimeLimit = 60 seconds; //can be set by the employer
    uint public OfferedPrice = 0.5 ether; //can be set by the employer
    uint public LowestPrice;
    uint WorkTime = 1000 seconds; //can be set by the employer
    uint MaxTime = 1000 seconds; //can be set by the employer
    uint MaxPrice = 0.5 ether; //can be set by the employer
    bool BiddingResult = false;
    
    //execution basic settings
    uint ConductStartTime;
    uint ConductTimeLimit = 1000 seconds; //can be set by the employer
    uint DepositEmployer = 0.5 ether; //can be set by the employer
    uint DepositBidder = 0.5 ether;//can be set by the employer
    uint public RandomThird;
    uint public Requiremrnts = 999; //can be set by the employer
    
    address public ThirdParty;
    
    //...
    bool EmployerSendDeposit = false;
    bool BidderSendDeposit = false;
    bool BidderUploadParameter = false;
    bool ThirdPartyUploadParamter = false;
    bool DecisionMaking = false;
    bool public TransactionDone = false;
    bool ReportSend = false;
    
    // //rollback
    // mapping(address => uint) Returns;
    
    //The creator of the smart contract
	constructor () public{
        Employer = msg.sender;
        BidStartTime = now;
    }
        
    //list of paticipants
    address w1 = 0x1B2660028aA1ca0596cFB292275d3f4a6B059e9F;
    address w2 = 0xB1f3190F8E64e5eCe0c164d3a5A4cda3807FE4dC;
    address w3 = 0x9Fb515E27fc648004e0c500360C623A5219b58C9;
    address w4 = 0x96B305299136367A3D2D6588Ac8b4aa8Dc5faA98;
    address w5 = 0x32183429755b87F0dC5ECc92115276A287140991;
    address w6 = 0xf229069Fc69e7B3038Ee54E31be86Bc742C3513e;
    address w7 = 0xea76ba6ebdf94b3d265b2bD78A15E5C2af3348a0;
    address w8 = 0x8e16CdbcA398f7fB91534a6b24e28e1FFf58b674;
    address w9 = 0x3d9175a9ebf0b59838cF6c1e43FA0F840E153d02;
    address w10 = 0x55A1c72D9ACa59A7AD2593ed397F8b6169f6264f;
    
    address tp1 = 0x9D607C7B72Eb860D28A17F37fe3880Ace52fa793;
    address tp2 = 0x0bEB5910932570e06765c51A622C51ae3b625EB3;
    address tp3 = 0xCBD2056d566c0240dC02a39f839b031eEc508A57;
    
    //bidding function
    function task_bid(uint OP, uint WT) public{
        if (now <= BidStartTime + BidTimeLimit){
            if (OP <= MaxPrice){
                if (WT <= MaxTime){
                    if (OP < OfferedPrice){
                        OfferedPrice = OP;
                        WorkTime = WT;
                        SuccessfulBidder = msg.sender;
                        BiddingResult = true;
                    }
                    else if (OP == OfferedPrice && WT <= WorkTime){
                        OfferedPrice = OP;
                        WorkTime = WT;
                        SuccessfulBidder = msg.sender;
                        BiddingResult = true;
                    }
                }
                else
                    revert("Unexpected time.");
            }
            else 
                revert("Unexpected price.");
        }
        else 
            revert("Time over.");
    }
    
    //employer sends the deposit to the smart contract
    function deposit_employer() public payable{
        if (now > BidStartTime + BidTimeLimit){
            ConductStartTime = now;
            if (BiddingResult == true){    
                if (now < ConductStartTime + ConductTimeLimit){
                    if (msg.sender == Employer){
                        if (msg.value == DepositEmployer){
                            EmployerSendDeposit = true;
                        }
                        else
                            revert("Incorrect amount.");
                    }
                    else
                        revert("Incorrect sender.");
                }
                else
                    revert("Time over");
            }
            else    
                revert("Wait for the previous step.");
        }
        else 
            revert("Bid is going on.");
    }
    
    //successful bidder sends the deposit to the smart contract
    function deposit_bidder() public payable{
        if (EmployerSendDeposit == true){
            if (now < ConductStartTime + ConductTimeLimit){
                if (msg.sender == SuccessfulBidder) {
                    if (msg.value == DepositBidder) {
                        BidderSendDeposit = true;
                    }
                    else
                        revert("Incorrect amount.");
                }
                else
                    revert("Incorrect sender.");
            }
            else 
                revert("Time over.");
        }
        else    
            revert("Wait for the previous step.");
    }
    
    //successful bidder uplaads its parameters
    function parameter_bidder(uint BQ) public{
        if (BidderSendDeposit == true){
            if (now < ConductStartTime + ConductTimeLimit){
                if (msg.sender == SuccessfulBidder){
                    if (Requiremrnts == BQ){
                        BidderUploadParameter = true;
                    }
                    else
                        revert("Requiremrnts are not met.");
                }
                else
                    revert("Incorrect sender.");
            }
            else
                revert("Time over.");
        }
        else
            revert("Wait for the previous step.");
    }
    
    //randomly choose the trusted third party
    uint public cont1 = 1;
    
    function random_third() public {
        if (cont1 == 1){
            RandomThird = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3; //can be adjusted according to the specific number of the trusted third parties
            cont1--;
        }
    }
    
    function parameter_third (uint TQ) public{
        if (BidderUploadParameter == true){
            if (now < ConductStartTime + ConductTimeLimit){
                if (RandomThird == 0){
                    ThirdParty = tp1;
                    if (msg.sender == ThirdParty){
                         if (Requiremrnts == TQ){
                            ThirdPartyUploadParamter = true;
                        }
                        else{
                            Employer.transfer(DepositEmployer);
                            SuccessfulBidder.transfer(DepositBidder);
                            revert("Requiremrnts are not met.");
                        }
                            
                    }
                    else
                        revert("Incorrect sender.");
                }
                else if (RandomThird == 1){
                    ThirdParty = tp2;
                    if (msg.sender == ThirdParty){
                        if (Requiremrnts == TQ){
                            ThirdPartyUploadParamter = true;
                        }
                        else{
                            Employer.transfer(DepositEmployer);
                            SuccessfulBidder.transfer(DepositBidder);
                            revert("Requiremrnts are not met.");
                        }
                    }
                    else
                        revert("Incorrect sender.");
                }
                else if (RandomThird == 2){
                    ThirdParty = tp3;
                    if (msg.sender == ThirdParty){
                        if (Requiremrnts == TQ){
                            ThirdPartyUploadParamter = true;
                        }
                        else{
                            Employer.transfer(DepositEmployer);
                            SuccessfulBidder.transfer(DepositBidder);
                            revert("Requiremrnts are not met.");
                        }
                    }
                    else
                        revert("Incorrect sender.");
                }
                else
                    revert("Error.");
            }
            else
                revert("Time over.");
        }
        else 
            revert("Wait for the previous step.");
    }
    
    uint Decision;
    
    function decision_transaction(uint D) public{
        if (msg.sender == Employer){
            if(ThirdPartyUploadParamter == true){
                Decision = D;
                if (Decision == 1){
                    TransactionDone = true;
                    DecisionMaking = true;
                }
                else if (Decision == 0){
                    TransactionDone = false;
                    DecisionMaking = true;
                }
                else
                    revert("Incorrect decision parameter.");
            }
        }
    }

    
    //randomly choose workers accroding to the number of totally commitment;
    uint public rw1;
    uint public rw2;
    uint public cont2 = 1;
    address public worker_member1;
    address public worker_member2;
    bool public SelectWorker = false;
    
    //randomly choose workers accroding to the number of committee members; 
    function report_choose_worker() public{
        if (cont2 == 1){
            if (DecisionMaking == true && TransactionDone == false){
                do{
                    rw1 = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10;
                    rw2 = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 10;
                    if (rw1 != rw2){
                        SelectWorker = true;
                        cont2--;
                        if (rw1 == 0){
                            worker_member1 = w1;
                        }
                        else if (rw1 == 1){
                            worker_member1 = w2;
                        }
                        else if (rw1 == 2){
                            worker_member1 = w3;
                        }
                         else if (rw1 == 3){
                            worker_member1 = w4;
                        }
                        else if (rw1 == 4){
                            worker_member1 = w5;
                        }
                        else if (rw1 == 5){
                            worker_member1 = w6;
                        }
                        else if (rw1 == 6){
                            worker_member1 = w7;
                        }
                        else if (rw1 == 7){
                            worker_member1 = w8;
                        }
                        else if (rw1 == 8){
                            worker_member1 = w9;
                        }
                        else if (rw1 == 9){
                            worker_member1 = w10;
                        }
                        
                        if (rw2 == 0){
                            worker_member2 = w1;
                        }
                        else if (rw2 == 1){
                            worker_member2 = w2;
                        }
                        else if (rw2 == 2){
                            worker_member2 = w3;
                        }
                         else if (rw2 == 3){
                            worker_member2 = w4;
                        }
                        else if (rw2 == 4){
                            worker_member2 = w5;
                        }
                        else if (rw2 == 5){
                            worker_member2 = w6;
                        }
                        else if (rw2 == 6){
                            worker_member2 = w7;
                        }
                        else if (rw2 == 7){
                            worker_member2 = w8;
                        }
                        else if (rw2 == 8){
                            worker_member2 = w9;
                        }
                        else if (rw2 == 9){
                            worker_member2 = w10;
                        }
                        
                    }
                    else
                        continue;
                }while(SelectWorker == false);
            }
            else
                revert("Cannot launch the report part.");
        }
        else  
            revert("Already done.");
    }
    
    //randomly choose trusted parties accroding to the number of committee members;
    uint public rtp1;
    uint public rtp2;
    uint public cont3 = 1;
    address public party_member1;
    address public party_member2;
    bool public SelectTrustedParty = false;
    
    function report_choose_party() public{
        if (cont3 == 1){
            if (DecisionMaking == true && TransactionDone == false){
                do{
                    rtp1 = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 3;
                    rtp2 = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 3;
                    if (rtp1 != rtp2){
                        SelectTrustedParty = true;
                        cont3--;
                        if (rtp1 == 0){
                            party_member1 = tp1;
                        }
                        else if (rtp1 == 1){
                            party_member1 = tp2;
                        }
                        else if (rtp1 == 2){
                            party_member1 = tp3;
                        }
                        
                        if (rtp2 == 0){
                            party_member2 = tp1;
                        }
                        else if (rtp2 == 1){
                            party_member2 = tp2;
                        }
                        else if (rtp2 == 2){
                            party_member2 = tp3;
                        }
                    }
                    else
                        continue;
                }while(SelectTrustedParty == false);
            }
            else
                revert("Cannot launch the report part.");
        }
        else
            revert("Already done.");
    }
    
    uint public vote1 = 1;
    uint public vote2 = 1;
    uint public vote3 = 1;
    uint public vote4 = 1;
    uint Option;
    uint public Agree = 0;
    uint public Disagree = 0;
    
    // members submit their results to the smart contract
    function submit_result(uint R) public{
        
        if (SelectTrustedParty == true && SelectWorker == true){
            if (msg.sender == worker_member1){
                Option = R;
                if (vote1 == 1){
                    if (Option == 1){
                        Agree++;
                        vote1--;
                    }
                    else if (Option == 0){
                        Disagree++;
                        vote1--;
                    }
                    else
                        revert("Error.");
                }
                else
                    revert("Voted.");
            }
            
            if (msg.sender == worker_member2){
                Option = R;
                if (vote2 == 1){
                    if (Option == 1){
                        Agree++;
                        vote2--;
                    }
                    else if (Option == 0){
                        Disagree++;
                        vote2--;
                    }
                    else
                        revert("Error.");
                }
                else
                    revert("Voted.");
            }
            
            if (msg.sender == party_member1){
                Option = R;
                if (vote3 == 1){
                    if (Option == 1){
                        Agree++;
                        vote3--;
                    }
                    else if (Option == 0){
                        Disagree++;
                        vote3--;
                    }
                    else
                        revert("Error.");
                }
                else
                    revert("Voted.");
            }
            
            if (msg.sender == party_member2){
                Option = R;
                if (vote4 == 1){
                    if (Option == 1){
                        Agree++;
                        vote4--;
                    }
                    else if (Option == 0){
                        Disagree++;
                        vote4--;
                    }
                    else
                        revert("Error.");
                }
                else
                    revert("Voted.");
            }
        }
    }
    
    //decision on the report
    function final_decision_report() public {
        if (vote1 == 0 && vote2 == 0 && vote3 == 0 && vote4 == 0){
            if (Agree > Disagree){
                //the smart contract sends deposit to the empolyer
                Employer.transfer(DepositEmployer);
                Employer.transfer(DepositBidder);
                TransactionDone = true;
            }
            else if (Agree < Disagree){
                //the smart contract sends deposti to the success bidder
                SuccessfulBidder.transfer(DepositEmployer);
                SuccessfulBidder.transfer(DepositBidder);
                TransactionDone = true;
            }
            else if (Agree == Disagree){
                //the smart contract sends deposti to each party
                Employer.transfer(DepositEmployer);
                SuccessfulBidder.transfer(DepositBidder);
                TransactionDone = true;
            }
        }
        else
            revert("Not all voted.");
    }
}
