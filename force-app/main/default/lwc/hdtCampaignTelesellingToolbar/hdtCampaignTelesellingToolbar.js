import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { loadScript } from 'lightning/platformResourceLoader';
import id from '@salesforce/user/Id';
export default class HdtCampaignTelesellingToolbar extends NavigationMixin(LightningElement) {
    showPanel = false;
    numberToCall = '';
    @api objectApiName;
    @api recordId;
    @track showRecallMe = false;
    @track showModal = false;
    @track toolbarAttributes = [];
    @track uuid = '';
    @track ecid = '';
    @track campaignMemberId;
    @api isSelectedDate ;
    @track selectedTimeSlot = [];
    @track dataList = [];
    @api startRangeValue;
    columnsList = [
        { label: 'Fascia Inizio', fieldName: 'startDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit'} },
        { label: 'Fascia Fine', fieldName: 'endDate', type: 'date', typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit'} },
    ];

    @api isHide = false;
    @track reiteklink;

    iconName = '';
    agentStatus = '';
    spinner = true;
    dialing = false;
    title = 'Scheda cliente';

    connectedCallback() {
        console.log('# connectedCallback #');
        this.iconName = 'utility:log_a_call';
        this.agentStatus = 'standard:employee_contact';
        this.campaignMemberId = this.recordId;
        console.log("memberID " + this.recordId);

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

    handleGetReitekLink(event){
        this.reiteklink = event.detail.reiteklink;
    }

    closeModal(){
        console.log('****BEFORESAVE');
        this.showModal = false;
       // window.TOOLBAR.EASYCIM.saveScript(this.uuid, "NO_ANSWER_BY_AGENT",true);
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
                   /* console.log('*******INSIDEPOPUP');
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
/*

                    if (this.ecid != '' && this.objectApiName == 'CampaignMember') {
                        this.showRecallMe = true;
                    }

                    //get campaignMemberId from openScript
                    console.log('******BEFOREOPENEVENT:');
                    window.TOOLBAR.EASYCIM.openScript(this.uuid,this.ecid).then(
                        function(data) { 
                            console.log('******DATAOPENSCRIPT:' + JSON.stringify(data)); 
                            window.TOOLBAR.EASYCIM.getContactInfo(this.uuid).then(
                                function(data) { console.log('******DATAOPENSCRIPTContactInfo:' + JSON.stringify(data)); }, function(err) {console.log("*******ErrorOpenScriptContact:",err); }
                            );
                    
                    
                    
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

                  /*  if (checkMemberId == true) {
                        //1st call - get available timeslots and fill the datatable

                        //redirect to campaignMember record page
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.campaignMemberId,
                                objectApiName: 'CampaignMember',
                                actionName: 'view'
                            },
                        });
                    }
                    count++;*/
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

    handleRecallMe() {
        console.log('handleRecallMe');
        this.template.querySelector("c-hdt-ct-toolbar-container").getSlot();
        
    }

    showModalPopup(event) {
        console.log('showModalPopup');
        //this.dataList = event.detail.data;        
        this.showModal = true;

    }
    handleDateChange(event){
        this.startRangeValue = event.target.value;
    }
    showModalSlot(event) {
        console.log('*******APPOINTMNET:' + JSON.stringify(event.detail));
        this.dataList = event.detail.data;
    }

    getSlotValues() {

        let start = this.template.querySelector('[data-id="dateR"]').value;
        console.log("TRYTRYTRY:" + start);
        this.template.querySelector("c-hdt-ct-toolbar-container").getSlotConfirm(start);
    }

    handleRowSelection2(event) {
        this.isSelectedDate = event.target.selectedRows[0];
        console.log(JSON.stringify(event.target.selectedRows));
    }

    handleSave() {
        //this.selectedTimeSlot = this.template.querySelector('lightning-datatable.timeSlotDT').getSelectedRows()[0];

        console.log(this.isSelectedDate);
        //if (this.selectedTimeSlot.length > 0) {
            //2nd call - post the selected timeslot

           // this.isSelectedDate
        this.template.querySelector("c-hdt-ct-toolbar-container").postAppointmentRequest(this.isSelectedDate);
        //}
        this.showModal = false;

        console.log('saved');
    }

    submitHandlerNegativeOutcome(event) {
        let status;
        if (event.detail.status) {
            status = event.detail.status;
            console.log('submitHandlerNegativeOutcome - ' + status);
            this.template.querySelector("c-hdt-ct-toolbar-container").saveScript(status, true);
        }
    }
}