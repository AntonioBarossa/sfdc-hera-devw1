import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivity from '@salesforce/apex/HDT_LC_ActivityIvaAccise.getInitActivity'
import saveAct from '@salesforce/apex/HDT_LC_ActivityIvaAccise.saveActivity'
import sospendi from '@salesforce/apex/HDT_LC_ActivityIvaAccise.sospendiActivity'
import riprendi from '@salesforce/apex/HDT_LC_ActivityIvaAccise.riprendiActivity'
import saveAttempt from '@salesforce/apex/HDT_LC_ActivityIvaAccise.saveAttempt'

export default class HdtActivityIvaAccise extends LightningElement {

    @api recordId;
    @api act;
    @api isAcciseGas = false;
    @api isAcciseEle = false;
    @api isSuspend = false;
    @api dateConfirm;
    @api showIva = false;
    @api showAccise = false;
    @api acciseOptions =[
        {label:"Elettrico", value:"Elettrico"},
        {label:"Gas", value:"Gas"}
    ];

     onchangeCheck(event){
         this.act[event.target.name] = event.target.checked;
         console.log('********:' + event.target.name);

        console.log('********:' + event.target.checked);   
     } 
    
    handleSave(){

        let checkIsAllFlag = true;
        let checkInitial = false;
        console.log('*******:' + JSON.stringify(this.act));
        console.log('*******:1');
        if(this.showAccise && !this.isAcciseGas && !this.isAcciseEle){
            const event = new ShowToastEvent({
                message: 'Scegli una Categoria di Accise',
                variant: 'error',
                mode: 'dismissable' 
                });
                this.dispatchEvent(event);
                console.log('*******:2');
                checkInitial = true;
        }
        else{
            if(this.showIva &&(!this.act.isIvaAnagrafici__c || !this.act.isIvaActivityCode__c || !this.act.isIvaSupplyAddress__c || !this.act.isIvaMatricola__c || !this.act.isIvaFirmLegalOwner__c || !this.act.isIvaCopyDocument__c || !this.act.isSchoolCategory__c || !this.act.isDenominazioneIncongruente__c || !this.act.isIva10Module__c || !this.act.isIvaAtecoCode__c )){
                checkIsAllFlag = false;
                console.log('*******:3');
            }
    
            if(this.showAccise && this.isAcciseEle && !this.act.PersonalData__c && !this.act.isAcciseSupply__c && !this.act.isAcciseContractualPower__c && !this.act.isAccisePdrPod__c && !this.act.isAcciseExclusionType__c && !this.act.isAcciseCopyTechnicalRelation__c && !this.act.AtecoCode__c && !this.act.IdentityDocument__c && !this.act.isAcciseExclusionModuleAccise__c && !this.act.isAcciseFirm__c){
                checkIsAllFlag = false;
                console.log('*******:4');
            }

            if(this.showAccise && this.isAcciseGas && !this.act.PersonalData__c && !this.act.isAcciseSupply__c && !this.act.isAccisePdrPod__c && !this.act.CraftsmenRegisterNumber__c && !this.act.CheckActivityBox__c && !this.act.AssociationStatute__c && !this.act.Signature__c && !this.act.CciaaData__c && !this.act.RequiredOfficeActivity__c && !this.act.IdentityDocument__c && !this.act.isAcciseModuleRequest__c && !this.act.CciaaSelfCertModule__c && !this.act.AtecoCode__c && !this.act.isIvaAnagrafici__c && !this.act.isIvaActivityCode__c && !this.act.isIvaSupplyAddress__c && !this.act.isIvaMatricola__c && !this.act.isIvaFirmLegalOwner__c && !this.act.isIvaCopyDocument__c && !this.act.isSchoolCategory__c && !this.act.isDenominazioneIncongruente__c && !this.act.isIva10Module__c && !this.act.isIvaAtecoCode__c){
                checkIsAllFlag = false;
                console.log('*******:5');
            }
        }
        if(!checkInitial){
            if(checkIsAllFlag){
                var today = new Date();
                const event = new ShowToastEvent({
                    message: 'Success',
                    variant: 'Success',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.dateConfirm = today.toISOString();
                    this.act.CompletationDateDocument__c = today.toISOString();
            }
            else{
                const event = new ShowToastEvent({
                    message: 'Per Completare Attivita bisogna fleggare tutti i campi',
                    variant: 'Warning',
                    mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
            }
            saveAct({ act : this.act,
                      closeActivity : checkIsAllFlag
                }).then({

                });
        }
    }

    handleSaveAttempt(){
        saveAttempt({
            actid : this.act.Id,
            attempt : this.act.NumberOfAttempt__c
        }).then({}); 
    }

    sospend(){
        sospendi({actid : this.act.Id}).then(response => {
            if(response){
                console.log('******HOLA');
                this.isSuspend = true;
            }
        });
    }

    handleRiprendi(){
        riprendi({actid : this.act.Id}).then(response => {
            if(response){
                this.isSuspend = false;
            }
        });
    }


    connectedCallback() {
        getActivity({recordId : this.recordId}).then(response =>{
            this.act = response;
            console.log('*****:' + JSON.stringify(response));
            console.log('*****:' + (response.Order__r != null && response.Order__r != undefined && response.Order__r.VATfacilitationFlag__c != null && response.Order__r.VATfacilitationFlag__c != undefined) ? response.Order__r.VATfacilitationFlag__c : false );
            this.showIva = (response.Order__r != null && response.Order__r != undefined && response.Order__r.VATfacilitationFlag__c != null && response.Order__r.VATfacilitationFlag__c != undefined) ? response.Order__r.VATfacilitationFlag__c : false ;
            this.showAccise = (response.Order__r != null && response.Order__r != undefined && response.Order__r.FacilitationExcise__c != null && response.Order__r.FacilitationExcise__c != undefined) ? response.Order__r.FacilitationExcise__c : false ;
            this.isSuspend = response.wrts_prcgvr__Status__c == 'Sospeso' ? true : false;
        });
    }
 
    changeAccise(event){
        if(event.detail.value == 'Elettrico'){
            this.isAcciseGas = false;
            this.isAcciseEle = true;
        }
        else{
            this.isAcciseGas = true;
            this.isAcciseEle = false;
        }
    }





}