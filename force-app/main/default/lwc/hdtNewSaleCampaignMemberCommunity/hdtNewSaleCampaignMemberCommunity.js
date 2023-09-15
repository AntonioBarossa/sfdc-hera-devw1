import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ObligatoryClientSurvey from '@salesforce/label/c.ObligatoryClientSurvey';
import getAccountAndCampaign from '@salesforce/apex/HDT_LC_CampaignsController.getAccountAndCampaign';
import getAlternativeAccount from '@salesforce/apex/HDT_LC_CampaignsController.getAccountId';
import getEcid from '@salesforce/apex/HDT_LC_CampaignsController.getEcid';
import getCurrentProfile from '@salesforce/apex/HDT_LC_CampaignsController.getCurrentProfile';


export default class hdtNewSaleCampaignMemberCommunity extends NavigationMixin(LightningElement) {
    @api recordId;
    CampaignProcessType = '';
    accountId='';
    isFromLead=false;
    @track ecid;
    @track firstLoginTime;
    @track currentUserProfile;
    // @track ctToolbarLogged = true;

    connectedCallback() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            this.CampaignProcessType = data.Campaign.ProcessType__c;
            console.log('CampaignProcessType Sale --> '+this.CampaignProcessType);
            if(data.ContactId != null && data.ContactId != undefined && data.ContactId != ''){
                this.isFromLead = false;
            }else if(data.LeadId != null && data.LeadId != undefined && data.LeadId != ''){
                this.isFromLead = true;
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });

        console.log('this.recordId --> '+this.recordId);

        getCurrentProfile({ 'campaignMemberId': this.recordId}).then(data => {
            this.currentUserProfile = data;
            
        }),error => {
            console.log('getCurrentProfile ERROR');
            console.log(error);
        };  

    }

    newSaleClick() {
        console.log('START newSaleClick');

              
        
        if(this.currentUserProfile === 'Hera Teleseller Partner User'){
            getEcid({ 'campaignMemberId': this.recordId}).then(data => {
                console.log("newSaleClick launch SUCCESS --> " + JSON.stringify(data));
                this.ecid = data;
                console.log('newSaleClick this.ecid --> '+this.ecid);
    
                if(this.ecid == ObligatoryClientSurvey){
                    console.log(this.ecid);
                    const evt = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: ObligatoryClientSurvey,
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else if(this.ecid != null && this.ecid != undefined && this.ecid != ''){
    
                    console.log('newSaleClick PUNTO 1');
                    this.launchClickToCall();
                    console.log('newSaleClick PUNTO 2');
    
                }
                else{
                    console.log('### newSaleClick ERRORE! Numero e/o ecid non trovati ###');
                    console.log('### newSaleClick this.ecid --> ',this.ecid,' ###');
                    const evt = new ShowToastEvent({
                        title: 'Attenzione!',
                        message: 'Ecid non trovato. Verificare e riprovare.',
                        variant: 'warning',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    
                }
                
            }),error => {
                console.log('newSaleClick ERROR');
                console.log(error);
            };        
        }
        else{
            this.navigateToNewSale();
        }
        
    }

    launchClickToCall(){
        
        console.log('launchClickToCall START');

        let getAgentIDPromise =  window.TOOLBAR.AGENT.getAgentID();
        let isTimeOver = false;

        let timeout = setTimeout(() => {
            
            console.log("Scattato il timeout della promise, verrà eseguito il codice del timeout");
            isTimeOver = true;
            const evt = new ShowToastEvent({
                title: 'Attenzione!',
                message: 'Non sei collegato alla barra. Continuazione della nuova vendita.',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            console.log('PRIMA DI NEW SALE');
            this.navigateToNewSale();
            console.log('DOPO NEW SALE');
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

    //#region Esecuzione gestione Click To Call
    checkOpenScript() {
        console.log('#### START checkOpenScript ####');
        console.log('#### checkOpenScript PUNTO 1 this.ecid --> ',this.ecid,' ####');
        
        let submitEcid = this.ecid;

        let openScriptNotPresent;

        openScriptNotPresent = this.checkValidityOpenScript();

        if(openScriptNotPresent === true){

            window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((data => {
                console.log('Nuova Vendita OPENSCRIPT ESEGUITA');

                if(data && data.result == true && data.terminated != true && data.readOnly != true){
                    console.log('checkOpenScript data OK');
                    localStorage.setItem("openScript-"+submitEcid , Date.now());
                    this.navigateToNewSale();
                    console.log('## checkOpenScript data --> '+JSON.stringify(data));
                    console.log('## checkOpenScript data.result --> '+data.result);
                    console.log('## checkOpenScript data.terminated --> '+data.terminated);
                    console.log('## checkOpenScript data.readOnly --> '+data.readOnly);
                    console.log('checkOpenScript value saved --> ',localStorage.getItem("openScript-"+submitEcid));
                    console.log('### checkOpenScript PUNTO 10 : data --> ',data,' ###');   
                }
                else{
                    console.log('#### checkOpenScript PUNTO 10.1 ####');
                    console.log('## checkOpenScript readOnly = true #');
                    console.log('## checkOpenScript data --> '+JSON.stringify(data));
                    console.log('## checkOpenScript data.result --> '+data.result);
                    console.log('## checkOpenScript data.terminated --> '+data.terminated);
                    console.log('## checkOpenScript data.readOnly --> '+data.readOnly);
                    //####  blocco attività  ####
                    try {
                        console.log('### checkOpenScript PUNTO 10.2 ###');
                        //alert("Errore! Non puoi effettuare la chiamata in questo momento.");
                        const evt = new ShowToastEvent({
                            title: 'Errore',
                            message: 'Il contatto è in gestione lato EasyCIM da altro operatore.',
                            variant: 'warning',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        console.log('#### checkOpenScript PUNTO 11 ####');
                    } catch (error) {
                        console.error('checkOpenScript ERRORE --> ',error);
                    }
                }
                
            }).bind(this), error => {
                console.log('checkOpenScript ERROR')
                console.log(error)
            });
        }
        else{

            console.log('openScript non eseguita perché già effettuata');
            this.navigateToNewSale();

        }
    }

    checkValidityOpenScript(){

        let ecidLoginTime;
        let submitEcid = this.ecid;
        console.log('PUNTO 1');
        if(localStorage.getItem("openScript-"+submitEcid) != null){
            console.log('PUNTO 2');
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);
            console.log('PUNTO 3: ecidLoginTime --> '+ecidLoginTime);
            console.log('PUNTO 4: this.firstLoginTime --> '+this.firstLoginTime);

            if(ecidLoginTime < this.firstLoginTime){
                console.log('PUNTO 5');
                localStorage.removeItem("openScript-"+submitEcid);
                console.log('PUNTO 6');
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


    navigateToNewSale() {
        getAccountAndCampaign({ campaignMemberId: this.recordId }).then(data => {
            console.log(JSON.stringify(data));
            if(data.ContactId != null && data.ContactId != undefined && data.ContactId != ''){
                this.isFromLead = false;
            }else if(data.LeadId != null && data.LeadId != undefined && data.LeadId != ''){
                this.isFromLead = true;
            }
            if (!data.Contact.AccountId) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Per procedere con la vendita si richiede di andare nel Account e procedere con Catalogo servizi', //HRAWRM-626 22/09/2021 EC
                        variant: "error"
                    })
                );
            } else {
                //navigate to new sale
                getAlternativeAccount({ campaignMemberId: this.recordId }).then(res => {
                    console.log('krist: '+res);
                    console.log('this.recordId --> '+this.recordId);
                    if(res){
                        this.accountId=res;
                    }
                    else {
                        this.accountId=data.Contact.AccountId;

                    }
                    console.log('KKKKKKK: '+this.accountId);

                    this[NavigationMixin.GenerateUrl]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "WizardVendita__c"
                        },
                        state: {
                            c__accountId: this.accountId,
                            c__campaignCommissioningId: data.CampaignId,
                            c__campaignId: data.CampaignId,
                            c__campaignMemberId: this.recordId
                        }
                    }).then(url => {
                        window.open(url, "_self");
                    });

                }).catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: `${error.status}`,
                            message: `${error.body.message}`,
                            variant: "error"
                        })
                    );
                });
               /* this[NavigationMixin.GenerateUrl]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "WizardVendita__c"
                    },
                    state: {
                        c__accountId: this.accountId,
                        c__campaignCommissioningId: data.CampaignId,
                        c__campaignMemberId: this.recordId
                    }
                }).then(url => {
                    window.open(url, "_self");
                });*/
            }
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: `${error.status}`,
                    message: `${error.body.message}`,
                    variant: "error"
                })
            );
        });
    }

    get manageDisable(){
        return this.CampaignProcessType == 'Nuovo Caso' || this.CampaignProcessType == '' || this.isFromLead;
    }
}