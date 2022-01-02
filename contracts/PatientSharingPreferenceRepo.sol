pragma solidity >=0.8.1;

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;

contract PatientSharingPreferenceRepo {
    /*
     * Patient records Struct
     * The preferenceValues are ordered as follows:
     * [DEMOGRAPHICS, MENTAL_HEALTH, BIOSPECIMEN, FAMILY_HISTORY, GENETIC, GENERAL_CLINICAL_INFORMATION, SEXUAL_AND_REPRODUCTIVE_HEALTH]
     */
    struct record {
        uint256 recordTime;
        bool[] preferenceValues; // this bol for now, to be changed later to byte
    }

    /*
     * Mappings
     */
    mapping(uint256 => uint256[]) StudyToPatient; // maps a studyID to list of patientIDs
    mapping(string => uint256) preferenceNames; // maps a prefernce name to its index in the ordered preferenceValues array
    mapping(string => record) preference; // mapping of key(StudyID, PatientID) to a patient record for that specific study. two uint(StudyID, PatientID) combined into a string to form the key "StudyID:PatientID"

    /*
     * set PreferenceName to index mapping
     */
    constructor() {
        preferenceNames["DEMOGRAPHICS"] = 0;
        preferenceNames["MENTAL_HEALTH"] = 1;
        preferenceNames["BIOSPECIMEN"] = 2;
        preferenceNames["FAMILY_HISTORY"] = 3;
        preferenceNames["GENETIC"] = 4;
        preferenceNames["GENERAL_CLINICAL_INFORMATION"] = 5;
        preferenceNames["SEXUAL_AND_REPRODUCTIVE_HEALTH"] = 6;
    }

    /*
     * Adds all preferences for one patient and one study at a time as an array of strings (preference names)
     * and an array of bool (preference values).
     *
     * Example:
     *
     * For patientId 2 and studyId 4 add preference ["RB1", "RET", "RYR1"] as [true, true, false].
     *
     * Also populates data structures used to keep track of pateintIds.
     */
    function addPreferences(
        uint256 _patientId,
        uint256 _studyId,
        uint256 _recordTime,
        string[] memory _preferenceNames,
        bool[] memory _preferenceValues
    ) public {
        // check if record already exist
        if (recordExists(_patientId, _studyId)) {
            //only update existing record
            //[TODO]
            return;
        }
        // add new patient to study mapping
        StudyToPatient[_studyId].push(_patientId);
        // add new patient record
        string memory key = getKey(_patientId, _studyId);
        record storage r = preference[key];
        r.recordTime = _recordTime;
        r.preferenceValues = _preferenceValues; // assuming input is ordered in the same way as declared above. [TODO]: check names before assigning values
    }

    /*
     * Takes a studyId and an array of preference names and returns all patientIds that have conscented to all preference names in the list.
     */
    function getConsentingPatientIds(
        uint256 _studyId,
        string[] memory _requestedSitePreferences
    ) public view returns (uint256[] memory) {
        // first get all patients in the study
        uint256[] memory patientList = StudyToPatient[_studyId];

        //check if the list is empty or not
        require(patientList.length != 0, "There are no patients in the given studyId");

        // it is not possible to create dynamic array so length must known
        // -> need to be adjusted later -> first know how many patients in the result then add them to the array
        uint256[] memory result = new uint256[](patientList.length); // for now add all patients in the study

        // preferenceName to index
        uint[] memory requestIndex = new uint[](_requestedSitePreferences.length);
        for(uint256 i = 0; i < _requestedSitePreferences.length; i++){
                requestIndex[i] = preferenceNames[_requestedSitePreferences[i]]; // get preferenceNames index
            }
        
        // loop through the list to find patients with _requestedSitePreferences
        uint count = 0; // count the number of matching patients
        bool[] memory pref;
        bool equal;
        for (uint256 i = 0; i < patientList.length; i++) {
            // check if preference is match - [TODO]: improve this 
            equal = true;
            for(uint256 j = 0; j < requestIndex.length; j++){
                //access preferences
                string memory key = getKey(patientList[i], _studyId);
                pref = preference[key].preferenceValues;
                //check if any value is false set equal to false
                if(pref[requestIndex[j]] == false){
                    equal = false; 
                }
            }
            if(equal == true){
                result[count] = patientList[i];  
                count++;
            }
        }
        // return the resulting patient ids
        return result;
    }

    /*
     *Additional functions
     */

    // Check if record exist
    function recordExists(uint256 _patientId, uint256 _studyId)
        internal
        pure
        returns (bool)
    {
        // [TODO]
        return false;
    }

    // function to compare if hash of two strings is equal
    function compareStringsHash(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return (keccak256(abi.encodePacked((a))) ==
                keccak256(abi.encodePacked((b))));
        }
    }

    // used to get key of combined StudyID and patientId -> ("StudyID:PatientID")
    function getKey(uint256 _patientId, uint256 _studyId)
        internal
        pure
        returns (string memory key)
    {
        string memory p = uint2str(_patientId);
        string memory s = uint2str(_studyId);
        string memory r = concatenate(s, ":");
        string memory k = concatenate(r, p);

        return k;
    }

    function concatenate(string memory s1, string memory s2)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(s1, s2));
    }

    // convert from uint -> String adapted from: https://github.com/provable-things/ethereum-api/blob/master/oraclizeAPI_0.5.sol#L1045
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + (j % 10)));
            j /= 10;
        }
        str = string(bstr);
    }

    // check if all bits are set to 1 (e.g. 11111 -> true) , help: https://www.geeksforgeeks.org/check-bits-number-set/ 
    function allBitsSet(uint n) internal pure returns (bool result){
        return false;
    }

}
