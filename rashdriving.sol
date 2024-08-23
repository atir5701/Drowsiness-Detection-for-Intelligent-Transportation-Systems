// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrafficControl {

    enum Penalty_Type { FINE , LICENCE_REVOKE }
    struct Vehicle {
        string plate_number;
        uint camera_id;
        uint owner_id;
    }


    struct Penalty {
        uint penalty_id;
        uint driver_id;
        string timestamp;
        Penalty_Type penalty_type;
        string plate_number;
        string location;
        bool is_reckless;
        bool is_drowsy;
        uint severity;
        uint fine_payable;
        string license_revocation_time;
    }

    struct Person {
        uint driver_id;
        string driver_image;
        uint[] owned_vehicles;
        uint[] penalties;
        bool is_license_revoked;
        string license_reissue_date;
        bool exists;
    }

    mapping(uint => Vehicle) public vehicles;
    mapping(uint => Penalty) public penalties;
    mapping(uint => Person) public people;

    uint public vehicleCount;
    uint public offenceCount;
    uint public penaltyCount;
    uint public personCount;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    
    function addPerson(uint driver_id, string memory driver_image) public {
        personCount++;
        people[personCount] = Person(
            driver_id,
            driver_image,
            new uint[](0),
            new uint[](0),
            false,
            "",
            true
        );
    }


    function addVehicle(string memory _plateNumber, uint _cameraId, uint _ownerId) public onlyOwner {
        require(people[_ownerId].exists, "Owner Not Registered");
        vehicleCount++;
        vehicles[vehicleCount] = Vehicle(_plateNumber, _cameraId, _ownerId);
    }

 
    function addPenalty(uint _driverId, string memory _timestamp, string memory _plate_number, string memory _location,bool _is_drowsy, bool _is_reckless) public onlyOwner {
        
        require(!_is_drowsy && !_is_reckless, "Why should Penalty be Imposed?");
        
        penaltyCount++;
        uint newPenaltyId = penaltyCount;
        uint _severity = 0;
        uint _finePayable;
        string memory _licenseRevocationTime;
        Penalty_Type pen_type;
        

        if(_is_drowsy && _is_reckless){
            _severity = 10;
            pen_type =  Penalty_Type.LICENCE_REVOKE;
            _finePayable  =5000;
            _licenseRevocationTime = "1 Month";
            revokeLicense(_driverId, _licenseRevocationTime);
        }
        else if(_is_drowsy){
            _severity = 3;
            pen_type =  Penalty_Type.FINE;
            _finePayable  =500;
            _licenseRevocationTime = "";
        }
        else{
            _severity = 7;
            pen_type =  Penalty_Type.FINE;
            _finePayable  =2000;
            _licenseRevocationTime = "";
        }


        penalties[newPenaltyId] = Penalty(newPenaltyId, _driverId, _timestamp, pen_type, _plate_number,_location,_is_reckless,_is_drowsy,_severity, _finePayable, _licenseRevocationTime);
        
        // Update the driver's penalties
        people[_driverId].penalties.push(newPenaltyId);
    }


    function revokeLicense(uint _driverId, string memory _revocationTime) public onlyOwner {
        people[_driverId].is_license_revoked = true;
        people[_driverId].license_reissue_date = _revocationTime;
    }

    function reissueLicense(uint _driverId) public onlyOwner {
        require(people[_driverId].is_license_revoked, "License is not revoked");
        
        people[_driverId].is_license_revoked = false;
        people[_driverId].license_reissue_date = "";
    }
}