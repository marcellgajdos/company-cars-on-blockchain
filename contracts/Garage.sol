// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./HR.sol";
import "./CarFactory.sol";
import "./StringUtils.sol";

contract Garage is CarFactory, HR, StringUtils{
    address public admin=msg.sender;
    struct Car{
        string make; 
        string modelID;
        uint32 dateOfPurchase; //format yyyymmdd or similar
        uint32 costOfPurchase; 
        uint32 milageWhenPurchased; //max is 4,294,967,295, should be enough for milage
        uint8 category; //max is 255, 0 is for currently serviced or no longer used cars
        uint32 currentMilage; 
        uint256 lastPickup;
        string lastDriver;
        bool occupied;
        uint256 tokenID;}
    mapping(string=>Car)public CarParameters;//registratonNumber => Car struct with parameters
    function G_SwitchAdmin(address _admin) public onlyOwner{
        admin=_admin;}
    function G_AddCar(
        string memory _registrationNumber,
        string memory _make, 
        string memory _modelID,
        uint32 _dateOfPurchase, //date format: "20220101" or similar, should not be 0
        uint32 _costOfPurchase, 
        uint32 _milageWhenPurchased,
        uint8 _category)public{
        CarParameters[_registrationNumber]=Car( _make, _modelID, _dateOfPurchase, _costOfPurchase, _milageWhenPurchased,_category,_milageWhenPurchased,block.timestamp," ",false,F_safeMint(admin,_registrationNumber));
        emit Event("Added: ", _registrationNumber);
        }
    function G_DeleteCar(string memory _registrationNumber)public onlyOwner{
        F_DestroyCar(CarParameters[_registrationNumber].tokenID);
        delete CarParameters[_registrationNumber];
        emit Event("Deleted: ", _registrationNumber);
        }
    function G_PickupCar(string memory _name, string memory _registrationNumber, uint32 _currentMilage) public{
        if(HR_IsEmployee(_name)==true&&G_GetDateOfPurchase(_registrationNumber)!=0){
            if(compare(HR_GetDrivenCar(_name),"")==0){//emp does not have a car
                if(HR_GetClearance(_name)<=CarParameters[_registrationNumber].category){//emp has proper clearance
                    if(CarParameters[_registrationNumber].occupied==false){//car is free
                        CarParameters[_registrationNumber].occupied=true;
                        CarParameters[_registrationNumber].currentMilage=_currentMilage;
                        CarParameters[_registrationNumber].lastDriver=_name;
                        CarParameters[_registrationNumber].lastPickup=block.timestamp;
                        F_TransferCar(msg.sender,EmployeeParameters[_name].walletAddress,CarParameters[_registrationNumber].tokenID);
                        HR_SetDrivenCar(_name,_registrationNumber);
                        emit Event("Picked up: ", _registrationNumber);
                    }
                    else{
                        emit Event("Failed Pickup","Car is not free");
                    }
                }
                else{
                    emit Event("Failed Pickup","Improper clearance");
                }
            }
            else{
                emit Event("Failed Pickup","Employee has a car");
            }
            }
        else{
            emit Event("Failed Pickup","Car or employee does not exist");
        }}
    function G_DropoffCar(string memory _name) public{
        string memory _registrationNumber=HR_GetDrivenCar(_name);//finds driven car and drops it off
        if(StringUtils.compare(_registrationNumber,"")!=0){
            transferFrom(HR_GetAddress(_name), admin, CarParameters[_registrationNumber].tokenID);
            CarParameters[_registrationNumber].occupied=false;
            EmployeeParameters[_name].drivenCar="";
            HR_SetDrivenCar(_name,"");
            emit Event("Dropped off: ", _registrationNumber);
        }
        else{
            emit Event("Cannot be dropped of:", "employee has no car");
        }
    }
    function G_GetMake(string memory _registrationNumber)public view returns (string memory){return CarParameters[_registrationNumber].make;}
    function G_GetModelID(string memory _registrationNumber)public view returns (string memory){return CarParameters[_registrationNumber].modelID;}
    function G_GetDateOfPurchase(string memory _registrationNumber)public view returns (uint32){return CarParameters[_registrationNumber].dateOfPurchase;}
    function G_GetCostOfPurchase(string memory _registrationNumber)public view returns (uint32){return CarParameters[_registrationNumber].costOfPurchase;}
    function G_GetMilageWhenPurchased(string memory _registrationNumber)public view returns (uint32){return CarParameters[_registrationNumber].milageWhenPurchased;}
    function G_GetCategory(string memory _registrationNumber)public view returns (uint8){return CarParameters[_registrationNumber].category;}
    function G_GetCurrentMilage(string memory _registrationNumber)public view returns (uint32){return CarParameters[_registrationNumber].currentMilage;}
    function G_GetLastPickup(string memory _registrationNumber)public view returns (uint256){return CarParameters[_registrationNumber].lastPickup;}
    function G_GetLastDriver(string memory _registrationNumber)public view returns (string memory){return CarParameters[_registrationNumber].lastDriver;}
    function G_GetOccupied(string memory _registrationNumber)public view returns (bool){return CarParameters[_registrationNumber].occupied;}
    function G_GetDriverAddress(string memory _registrationNumber)public view returns(address){return ownerOf(CarParameters[_registrationNumber].tokenID);}
}
