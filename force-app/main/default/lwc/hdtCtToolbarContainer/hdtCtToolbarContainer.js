import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { loadScript } from 'lightning/platformResourceLoader';
import id from '@salesforce/user/Id';
import OBJECT_NAME from '@salesforce/schema/CampaignMember';
import postSlotRequest from '@salesforce/apex/HDT_LC_RecallMe.postSlotRequest';
import postAppointment from '@salesforce/apex/HDT_LC_RecallMe.postAppointment';

export default class HdtCtToolbarContainer extends NavigationMixin(LightningElement) {
    
    showPanel = true;
    numberToCall = '';
    @api objectApiName;
    @track showRecallMe = false;
    @track showModal = false;
    @track toolbarAttributes = [];
    @track uuid = '';
    @track ecid = '';
    @api campaignMemberId;
    @track selectedTimeSlot = [];
    @track dataList = [];
    columnsList = [
        { label: 'StartDate', fieldName: 'StartDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit'} },
        { label: 'EndDate', fieldName: 'EndDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit'} },
    ];

    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    title = 'Scheda cliente';

    connectedCallback() {
        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';

        window.addEventListener('toolbarCallBack', this.contactCallback);

        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => console.log('# javascript Loaded #'))
        .catch(error => console.log('promise error: ' + error));

       /* setTimeout(() => {
            this.enableCallback();
            this.spinner = false;           
        }, 1000);*/

    }

    closeModal(){
        console.log('****BEFORESAVE:'+ this.campaignMemberId);
       // window.TOOLBAR.EASYCIM.saveScript(this.uuid, "NO_ANSWER_BY_AGENT",true);
       this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.campaignMemberId,
            objectApiName: OBJECT_NAME.objectApiName,
            actionName: 'view'
        },
    });
        console.log('****AFTERSENDSAVE');
    }

    toolbarEvent(event) {
        console.log('>>> toolbarEvent');
        console.log('********** EVENT TYPE > ' + event.detail.eventType);
        console.log('>>> EVENT OBJ > ' + JSON.stringify(event.detail.eventObj));

        let eventType = event.detail.eventType;
        eventType = eventType.toUpperCase();
        let callData = [];
        let checkMemberId = false;
        let count = 0;

        switch (eventType) {
            case 'POPUP':
                //if (count == 0) {
                    console.log('*******INSIDEPOPUP');
                    this.toolbarAttributes = event.detail.eventObj;
                    this.uuid = this.toolbarAttributes.id;
                    callData = event.detail.CallData;
                    //get ecid value from callData
                    this.ecid = window.TOOLBAR.CONTACT.GetCallDataValueByName(this.toolbarAttributes, "ECID");
                    /*callData.forEach(elem => {
                        if (elem != null && elem.name == 'ECID' && elem.value != null && elem.value != '') {
                            this.ecid = elem.value;
                        }
                    });*/


                    if (this.ecid != '' && this.objectApiName == 'CampaignMember') {
                        this.showRecallMe = true;
                    }

                    //get campaignMemberId from openScript
                    console.log('******BEFOREOPENEVENT:');
                    window.TOOLBAR.EASYCIM.openScript(this.uuid,this.ecid).then(
                        function(data) { 
                            console.log('******DATAOPENSCRIPT:' + JSON.stringify(data)); 
                           /* window.TOOLBAR.EASYCIM.getContactInfo(this.uuid).then(
                                function(data) { 
                                    console.log('******DATAOPENSCRIPTContactInfo:' + JSON.stringify(data));
                                    let varSplit = data.ContactInfo[0].value.split(" ");
                                    console.log('******DATAOPENSCRIPTContactInfo2:');
                                    this.campaignMemberId = varSplit[4];
                                    let cmp = varSplit[4];
                                    console.log("*****CampaignMember:" + this.campaignMemberId );
                                   // if (checkMemberId == true) {
                                        //1st call - get available timeslots and fill the datatable
                
                                        //redirect to campaignMember record page
                                        console.log('CMP:' + cmp );
                                    this[NavigationMixin.Navigate]({
                                        type: 'standard__recordPage',
                                        attributes: {
                                            recordId: cmp,
                                            objectApiName: 'CampaignMember',
                                            actionName: 'view'
                                        },
                                    });
                                    //}
                            
                            }, function(err) {console.log("*******ErrorOpenScriptContact:",err); }
                            );*/
                            // da Abilitare Domani
                             let dataArray = data.listFieldValueList;
                             console.log("******DataArray:" + dataArray);
                            for (let i = 0; i < dataArray.length; i++) {
                                if(dataArray[i].fieldName == 'campaignmemberid' || dataArray[i].fieldName == 'campaignMemberId'){
                                    this.campaignMemberId = dataArray[i].value;
                                    console.log('CAMPAINGCHECK:' + this.campaignMemberId);
                                    break;
                                }
                            } 
                            
                            
                    
                    
                    
                    }, function(err) { console.log("*******ErrorOpenScript:",err);}
                      );

                   
                   
                  /*  let responseObj = JSON.parse(response);
                    let listFieldValueList = responseObj.customerInfo.listFieldValueList;
                    listFieldValueList.forEach(elem => {
                        if (elem != null && elem.categorizedFieldKeyCode == 'campaignMember Id' && this.checkMemberId == false) {
                            this.campaignMemberId = elem.value;
                            this.checkMemberId = true;
                        }
                    });*/

                    
                    //count++;
               // }
                break;

            case 'ESTABLISHED':
               /* this.toolbarAttributes = event.detail.eventObj;
                this.uuid = this.toolbarAttributes.uuid;*/

                break;

            default:
                break;
        }
    }

    callThisNumber() {
        this.template.querySelector("c-hdt-ct-toolbar").callNumberFromParent(this.numberToCall);
    }

    hangup() {
        this.template.querySelector("c-hdt-ct-toolbar").hangUpFromParent();
    }

    /*handleRecallMe() {
        let dt = new Date();
        //sample data for testing
        this.dataList = [
            {
                'id': 'ts1',
                'StartDate' : dt.toString(),
                'EndDate' : dt.toString()
            },
            {
                'id': 'ts2',
                'StartDate' : dt.toString(),
                'EndDate' : dt.toString()
            },
            {
                'id': 'ts3',
                'StartDate' : dt.toString(),
                'EndDate' : dt.toString()
            },
            {
                'id': 'ts4',
                'StartDate' : dt.toString(),
                'EndDate' : dt.toString()
            },
        ];
        
        this.showModal = true;
    }*/

   /* handleRowSelection(event) {
        console.log(event.target.selectedRows[0]);
    }*/

   /* handleSave() {
        this.selectedTimeSlot = this.template.querySelector('lightning-datatable.timeSlotDT').getSelectedRows()[0];
        console.log(this.selectedTimeSlot);
        //2nd call - post the selected timeslot
        console.log('saved');
    }*/
}