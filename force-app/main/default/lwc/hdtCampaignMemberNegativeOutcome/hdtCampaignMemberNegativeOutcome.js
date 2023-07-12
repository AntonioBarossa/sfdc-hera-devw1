import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCampaignMemberStatusValue from '@salesforce/apex/HDT_LC_CampaignsController.updateCampaignMemberStatus';
import getNegativeOutcomeValues from '@salesforce/apex/HDT_LC_CampaignsController.getOutcomeValues';
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';
import getCurrentProfile from '@salesforce/apex/HDT_LC_CampaignsController.getCurrentProfile';



export default class HdtCampaignMemberNegativeOutcome extends LightningElement {
    @track isModalOpen = false;
    @track value;
    @track ecid;
    @track firstLoginTime;
    @api campaignMemberId;
    @track currentUserProfile;


    options;

    // options = [
    //     { value: 'Black List', label: 'Black List' },
    //     { value: 'Già Cliente', label: 'Già Cliente' },
    //     { value: 'Da poco con altro Gestore', label: 'Da poco con altro Gestore' },
    //     { value: 'Cliente non coperto rete gas', label: 'Cliente non coperto rete gas' },
    //     { value: 'Non interessato all offerta', label: 'Non interessato all offerta' },
    //     { value: 'Prima attivazione', label: 'Prima attivazione' },
    //     { value: 'Script completato', label: 'Script completato' },
    //     { value: 'Riaggancia e rifiuta il contatto', label: 'Riaggancia e rifiuta il contatto' },
    //     { value: 'Fuori Target', label: 'Fuori Target' },
    //     { value: 'Titolare della fornitura non disponibile', label: 'Titolare della fornitura non disponibile' },
    //     { value: 'La proposta non è competitiva', label: 'La proposta non è competitiva' }
    // ];

    connectedCallback(){
        getCurrentProfile({ 'campaignMemberId': this.recordId}).then(data => {
            this.currentUserProfile = data;
            
        }),error => {
            console.log('getCurrentProfile ERROR');
            console.log(error);
        };  
    }

    negativeResultClick() {

        console.log('window --> '+window);
        console.log('window.TOOLBAR --> '+TOOLBAR);

        getNegativeOutcomeValues({'campaignMemberId': this.campaignMemberId , 'outcomeType': 'Utile Negativo'}).then(result => {

            this.options = [];

            console.log('result --> '+JSON.stringify(result));
            var conts = result;
            for(var key in conts){
                console.log('conts[key] --> '+conts[key]);
                console.log('key --> '+key);
                const option = {
                    label: key,
                    value: conts[key]
                };

                if(this.options != undefined){
                    this.options = [...this.options, option];
                }
                else{
                    this.options = [option];
                }

            }

            console.log('this.options --> '+JSON.stringify(this.options));

            if(this.currentUserProfile === 'Hera Teleseller Partner User'){
                getEcid({ 'campaignMemberId': this.campaignMemberId}).then(data => {
                    console.log("getEcid launch SUCCESS --> " + JSON.stringify(data));
                    this.ecid = data;
                    console.log('this.ecid --> '+this.ecid);
                }).catch(err => {
                    console.log(err);
                });
            }
            
        })
        .catch(error => {
            alert(JSON.stringify(error));
        });
    
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    launchClickToCall(){

        console.log('launchClickToCall START');
        if(this.currentUserProfile === 'Hera Teleseller Partner User'){

            let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
            let isTimeOver = false;

            let timeout = setTimeout(() => {
                
                console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
                isTimeOver = true;
                const evt = new ShowToastEvent({
                    title: 'Attenzione!',
                    message: 'Non sei collegato alla barra.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                console.log('PRIMA DI SUBMITDETAILS');
                this.submitDetails();
                console.log('DOPO SUBMITDETAILS');
            }, 2000);
            
            console.log('DOPO TIMEOUT');

            getAgentIDPromise.then((data) => {
                window.clearTimeout(timeout);
                if (!isTimeOver) {
                    console.log('getAgentID SUCCESS');
                    if (typeof data !== "undefined") {
                        console.log('data != undefined');
                        window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
                            console.log('getAgentStateByID SUCCESS');
                            if (typeof agentState === "object") {
                                console.log('agentState = OBJECT');
                                console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
                                this.firstLoginTime = agentState.FirstLoginTime;
                                console.log('ARRIVATO PRIMA DI LANCIO CHECK OPEN SCRIPT');
                                if(agentState.State === 'AGENT:PAUSE'){
                                    const evt = new ShowToastEvent({
                                        title: 'Attenzione!',
                                        message: 'Per proseguire verificare che lo stato della barra sia "disponibile". ',
                                        variant: 'warning',
                                        mode: 'dismissable'
                                    });
                                    this.dispatchEvent(evt);
                                }
                                else{
                                    this.checkOpenScript();
                                }
                            }
                        }).bind(this), error => {
                            console.log('getAgentStateByID ERROR');
                            console.log(error)
                        };
                    }
                    console.log("Promise risolta, codice eseguito");
                } else {
                    isTimeOver = false
                    console.log("Promise risolta dopo il timeout, NON è stato eseguita il codice nella THEN");
                }
            

            }).catch(err => {
                    console.log('getAgentIDPromise ERROR');
                    console.log(err);
                });
        }
        else{
            this.submitDetails();
        }
    }

     //#region Esecuzione gestione Click To Call
     checkOpenScript() {
        console.log('#### START checkOpenScript ####');
        console.log('#### checkOpenScript PUNTO 1 this.ecid --> ',this.ecid,' ####');
        
        let submitEcid = this.ecid;

        let openScriptNotPresent;

        openScriptNotPresent = this.checkValidityOpenScript();

        if(openScriptNotPresent === true){

            window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((data => {
                console.log('Esito Negativo OPENSCRIPT ESEGUITA');

                if(data && data.result == true && data.terminated != true && data.readOnly != true){
                    console.log('openScript data OK');
                    localStorage.setItem("openScript-"+submitEcid , Date.now());
                    this.submitDetails();
                    console.log('openScript value saved --> ',localStorage.getItem("openScript-"+submitEcid));
                    console.log('### openScript PUNTO 10 : data --> ',data,' ###');   
                }
                else{
                    console.log('#### openScript PUNTO 10.1 ####');
                    console.log('## openScript readOnly = true #');
                    console.log('## openScript data --> '+JSON.stringify(data));
                    console.log('## openScript data.result --> '+data.result);
                    console.log('## openScript data.terminated --> '+data.terminated);
                    console.log('## openScript data.readOnly --> '+data.readOnly);
                    //####  blocco attività  ####
                    try {
                        console.log('### openScript PUNTO 10.2 ###');
                        //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                        const evt = new ShowToastEvent({
                            title: 'Errore',
                            message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        console.log('#### openScript PUNTO 11 ####');
                    } catch (error) {
                        console.error('openScript ERRORE --> ',error);
                    }
                }
                
            }).bind(this), error => {
                console.log('ERROR')
                console.log(error)
            });
        }
        else{

            console.log('openScript non eseguita perché già effettuata');
            this.submitDetails();

        }
    }

    checkValidityOpenScript(){

        let ecidLoginTime;
        let submitEcid = this.ecid;

        if(localStorage.getItem("openScript-"+submitEcid) != null){
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);

            if(ecidLoginTime < this.firstLoginTime){
                localStorage.removeItem("openScript-"+submitEcid);
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return true;
        }

    }
    //#endregion

    submitDetails() {
        console.log('submitDetails START');
        console.log('this.value --> '+this.value);
        updateCampaignMemberStatusValue({ 'campaignMemberId': this.campaignMemberId, 'statusValue': this.value }).then(data => {
            console.log("ok" + JSON.stringify(data));
            this.isModalOpen = false;
            // let status = this.value;
            const status = [this.value, this.ecid];
            this.dispatchEvent(new CustomEvent('aftersubmit', { detail: {status} }));
        }).catch(err => {
            console.log(err);
        });
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log(this.value);
    }

}