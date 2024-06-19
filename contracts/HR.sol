// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract HR is Ownable{
    event Event(string,string);
    struct Employee{
        uint8 clearance;
        address walletAddress;
        string drivenCar;
        bool exists;}
    mapping (string=>Employee) public EmployeeParameters; //employee name => employee parameters
    
    function HR_AddEmployee(string memory _name, uint8 _clearance, address _walletAddress)public onlyOwner{
        EmployeeParameters[_name]=Employee(_clearance,_walletAddress, "", true);
        emit Event("Added: ", _name);}
    function HR_ModifyEmployee(string memory _name,uint8 _clearance,address _walletAddress)public onlyOwner{
        EmployeeParameters[_name].clearance=_clearance;
        EmployeeParameters[_name].walletAddress=_walletAddress;
        emit Event("Modified: ", _name);}
    function HR_DeleteEmployee(string memory _name)public onlyOwner{
        delete EmployeeParameters[_name];
        emit Event("Deleted: ", _name);}
    function HR_GetClearance(string memory _name)public view returns(uint8){
        return EmployeeParameters[_name].clearance;}
    function HR_GetAddress(string memory _name)public view returns(address){
        return EmployeeParameters[_name].walletAddress;}
    function HR_SetDrivenCar(string memory _name, string memory _registrationNumber)internal{
        EmployeeParameters[_name].drivenCar=_registrationNumber;}
    function HR_GetDrivenCar(string memory _name) public view returns(string memory){
        return EmployeeParameters[_name].drivenCar;}
    function HR_IsEmployee(string memory _name) public view returns (bool){
        if (EmployeeParameters[_name].exists){
            return true;
        }
        else{return false;}}
}