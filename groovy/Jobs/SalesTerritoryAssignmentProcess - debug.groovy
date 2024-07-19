/***********************************************************************************************/
/* Created : Originally by Jack Dorrance for the Plan to Win Map project (Sales Dashboards)    */
/*      Updated on May 20, 2024 by RJ Agnello to implement indexing for performance reasons    */
/*      As well as to extend the application to more than just closed records (and affect      */
/*      historical data as well since we need 2years worth of records for reporting.           */
/* Purpose : Looks against the Lead Territory Assignment custom object for a territory to      */
/*      assign to a Job                                                                        */
/* Duration : Function - triggered by scheduled process                                        */
/* Object : Jobs (Service Request) but queries LeadTerritoryAssignment_c                       */
/* Concerns : None at the moment                                                               */
/***********************************************************************************************/
def startTime = now();
def returnMessageTemp = ''
def recordsToParse = 7500 //variable to determine how many records to run against.
def today = now() + 1//new Date()
def timeframeStart = today - 730
/* Step 1 - Grab the data from the Lead Territory Assigment object. This will be used to create the indexed lists */
  def voLTA = newView('LeadTerritoryAssignment_c')
  def vcLTA = voLTA.createViewCriteria()
  def vcRowLTA = vcLTA.createRow()
  def vc1LTA = vcRowLTA.ensureCriteriaItem('RecordName')
    vc1LTA.setOperator('<>')
    vc1LTA.setValue(null)
    vcLTA.insertRow(vcRowLTA)
    voLTA.appendViewCriteria(vcLTA)
    voLTA.setMaxFetchSize(35000) //Currently under 24k records for USA, and ~500 for Canada. Not probable that it would expand beyond 35k.
    voLTA.executeQuery()

  // The indexed arrays
  def arrayCanKey = []
  def array0Key = []
  def array1Key = []
  def array2Key = []
  def array3Key = []
  def array4Key = []
  def array5Key = []
  def array6Key = []
  def array7Key = []
  def array8Key = []
  def array9Key = []
  def arrayCanVal = []
  def array0Val = []
  def array1Val = []
  def array2Val = []
  def array3Val = []
  def array4Val = []
  def array5Val = []
  def array6Val = []
  def array7Val = []
  def array8Val = []
  def array9Val = []

  while (voLTA.hasNext()){
    def row = voLTA.next();
    def arrayIndex = '';
    def key = '';
    def val = 0.0;
    if (row.Country_c == 'United States') {
        arrayIndex = left(row?.Zip_c, 1) //Need to take the first digit of the postal code, and use that to determine the array/list to utilize. 
        key = row?.Zip_c
        val = row?.Territory_Id_c
    } else {
        arrayIndex = 'CAN'
        key = row?.FSA_c
        val = row?.Territory_Id_c
    }
    if (key && val){
        key = key.toString();
    switch(arrayIndex) {
        case '0': 
            array0Key.add(key);
            array0Val.add(val);
            break
        case '1': 
            array1Key.add(key);
            array1Val.add(val);
            break
        case '2': 
            array2Key.add(key);
            array2Val.add(val);
            break
        case '3': 
            array3Key.add(key);
            array3Val.add(val);
            break
        case '4': 
            array4Key.add(key);
            array4Val.add(val);
            break
        case '5': 
            array5Key.add(key);
            array5Val.add(val);
            break
        case '6': 
            array6Key.add(key);
            array6Val.add(val);
            break
        case '7': 
            array7Key.add(key);
            array7Val.add(val);
            break
        case '8': 
            array8Key.add(key);
            array8Val.add(val);
            break
        case '9': 
            array9Key.add(key);
            array9Val.add(val);
            break
        case 'CAN': 
            arrayCanKey.add(key);
            arrayCanVal.add(val);
            break
        default:
            break
    }
  }
}

//Build the query for Service Requests
def vo = newView('ServiceRequestVO')
def vc = newViewCriteria(vo)

//vcr1 = needs to be updated + not cancelled + has a post code + within 2 years since JobEndDate
def vcr1 = vc.createRow()
def vci1_1 = vcr1.ensureCriteriaItem('LastSalesTerritoryAssignedDate_c')
vci1_1.setOperator('BEFORE')
vci1_1.setValue(today);

def vci1_2 = vcr1.ensureCriteriaItem('JobStatus_c')
vci1_2.setOperator('<>')
vci1_2.setValue('Cancelled');

// def vci1_3 = vcr1.ensureCriteriaItem('PostalCode_c')
// vci1_3.setOperator('ISNOTBLANK')
def vci1_3 = vcr1.ensureCriteriaItem('PostalCode_c')
vci1_3.setOperator('=')
vci1_3.setValue('65067');


def vci1_4 = vcr1.ensureCriteriaItem('CreationDate')
vci1_4.setOperator('AFTER')
vci1_4.setValue(timeframeStart); //easy way to remove 2 years (365*2)

//insert this criteria row (vcr1)
vc.insertRow(vcr1);

//vcr2 = never been updated + not cancelled + has a post code + within 2 years since JobEndDate
def vcr2 = vc.createRow();
def vci2_1 = vcr2.ensureCriteriaItem('LastSalesTerritoryAssignedDate_c')
vci2_1.setOperator('ISBLANK')

def vci2_2 = vcr2.ensureCriteriaItem('JobStatus_c')
vci2_2.setOperator('<>')
vci2_2.setValue('Cancelled');


// def vci2_3 = vcr2.ensureCriteriaItem('PostalCode_c')
// vci2_3.setOperator('ISNOTBLANK')

def vci2_3 = vcr2.ensureCriteriaItem('PostalCode_c')
vci2_3.setOperator('=')
vci2_3.setValue('65067');

def vci2_4 = vcr2.ensureCriteriaItem('CreationDate')
vci2_4.setOperator('AFTER')
vci2_4.setValue(timeframeStart); //easy way to remove 2 years (365*2)
vc.insertRow(vcr2);

vo.appendViewCriteria(vc);
vo.executeQuery();
vo.setMaxFetchSize(recordsToParse)

def recordsProcessed = 0;
def recordsSuccessful = 0;
def recordsSkipped = 0;
while (vo.hasNext()){
    def rowSR = vo.next()
    def postCode = rowSR.PostalCode_c
    def territoryId = null;
    def index = null;
    if(postCode != null){
        recordsProcessed++;
        if (length(postCode) == 7){ //denotes Canadian postal
            postCode = left(postCode,3) //transform to FSA
            index = arrayCanKey.indexOf(postCode)
            if(index > -1){
            territoryId = arrayCanVal[index];
            }
        } else {
            def zipLeadingChar = left(postCode,1)
            postCode = left(postCode,5) //transform to standard US postcode
            switch(zipLeadingChar) {
                case '0': 
                    index = array0Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found. 
                    territoryId = array0Val[index];
                    }
                    break
                case '1':   
                    index = array1Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array1Val[index];
                    }
                    break
                case '2': 
                    index = array2Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array2Val[index];
                        }
                    break
                case '3': 
                    index = array3Key.indexOf(postCode)
                    println(index)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array3Val[index];
                        }
                    break
                case '4': 
                      index = array4Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array4Val[index];
                                          }
                    break
                case '5': 
                    index = array5Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array5Val[index];
                        }
                    break
                case '6': 
                    index = array6Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array6Val[index];
                        }
                    break
                case '7': 
                    index = array7Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array7Val[index];
                        }
                    break
                case '8': 
                    index = array8Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array8Val[index];
                        }
                    break
                case '9': 
                    index = array9Key.indexOf(postCode)
                    if(index > -1){ //2024.07.16|INC0032394 - Added because the index, if not found, can actually be returned as -1 instead of null. We ONLY want to leverage it if one is actually found.
                    territoryId = array9Val[index];
                        }
                    break
                default: 
                    break 
            }
                returnMessageTemp = returnMessageTemp + "zipLeadingChar is " + zipLeadingChar;
        }
        if(rowSR.SalesTerritory_Id_c != territoryId) {
            rowSR.setAttribute('SalesTerritory_Id_c',territoryId)
        }
    }
    territoryId ? recordsSuccessful++ : recordsSkipped++ //ternary to update the counts for logging
    returnMessageTemp = returnMessageTemp + ", territory value for " + postCode + " is " + territoryId     
    //rowSR.setAttribute('LastSalesTerritoryAssignedDate_c', today) //Commented out for debugging - we don't want to clear out our records that are being used while testing. 
    returnMessageTemp = returnMessageTemp + "index " + index;

}

def endTime = now();
long diffInMills = endTime.getTime() - startTime.getTime(); //This is potentially inaccurate, but it gives an idea. 
def processCounterDenom = 1; //added to support calculating the time spent running, which to avoid a div by zero instance, needs to be a separate variable than the recordsProcessed var
if(recordsProcessed > 0){
    processCounterDenom = recordsProcessed;
} 
def durationEach = (diffInMills / processCounterDenom) / 1000
return "Duration of runtime: "     + diffInMills / 1000  + ", records processed: " + recordsProcessed + ", records successful: " + recordsSuccessful + ", records skipped: " + recordsSkipped + " Average run time: " + durationEach + " " + returnMessageTemp + "today is " + today