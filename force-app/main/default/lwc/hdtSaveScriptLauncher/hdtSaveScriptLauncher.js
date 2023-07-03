import { LightningElement,api,track } from 'lwc';
import getCachedUuid from '@salesforce/apex/HDT_LC_CtToolbar.getCachedUuid';    // params: n/a
import cttoolbar from '@salesforce/resourceUrl/toolbar_sdk';
import { loadScript } from 'lightning/platformResourceLoader';

export default class HdtSaveScriptLauncher extends LightningElement {

    @track ecid;
    @track firstLoginTime;
    externalWindow;

    connectedCallback(){

        //this.getFirstLoginTime();

        Promise.all([
            loadScript(this, cttoolbar)
        ]).then(() => console.log('# javascript Loaded #'))
        .catch(error => console.log('promise error: ' + error));
        
    }

    @api launcherTest(){
        console.log('LAUNCHER FUNZIONANTE');
    }

     @api async getFirstLoginTime(ecidFromAura, esito, isResponsed){

        // window.TOOLBAR.AGENT.getAgentID().then((data) => {
        //     if (typeof data !== "undefined") {
        //         window.TOOLBAR.AGENT.getAgentStateByID(data).then((agentState) => {
        //             if (typeof agentState === "object") {
        //                 console.log("ID:", agentState.ID, "FirstLoginTime:", agentState.FirstLoginTime, "agentState:", agentState);
        //                 this.firstLoginTime = agentState.FirstLoginTime;
        //             }
        //         });
        //     }
        // });

        try {
            console.log('launchClickToCall START');


            this.ecid = ecidFromAura;
    
            console.log('PUNTO DI ROTTURA');
    
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
                console.log('PRIMA DI launchNewCaseWizard');
                this.saveScriptEcid(esito, isResponsed);
                console.log('DOPO launchNewCaseWizard');
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
                                    this.saveScriptEcid(esito, isResponsed);

                                }
                                //this.saveScriptEcid(esito, isResponsed);
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
            
            });
            // }).catch(err => {
            //         console.log('getAgentIDPromise ERROR');
            //         console.log(err);
            // });

        } catch (e) {
            console.log('getAgentIDPromise ERROR');
            console.log(err);
        }
        return "Nothing found";
    }

    saveScriptEcid(esito, isResponsed) {
        console.log('SAVESCRIPT LAUNCHER : saveScriptEcid esito --> '+esito);
        console.log('SAVESCRIPT LAUNCHER : saveScriptEcid isResponsed --> '+isResponsed);
        if(this.ecid != null && this.ecid != undefined && this.ecid != ''){
            //controllo openScript
            console.log('#### START checkOpenScript ####');
            console.log('#### checkOpenScript PUNTO 1 this.ecid --> ',this.ecid,' ####');
            
            let submitEcid = this.ecid;
    
            let openScriptNotPresent = this.checkValidityOpenScript();
    
            if(openScriptNotPresent === true){
    
                window.TOOLBAR.EASYCIM.openScript("", submitEcid, true).then((async data => {
                    console.log('Nuovo Caso saveScriptLauncher OPENSCRIPT ESEGUITA');
    
                    if(data && data.result == true && data.terminated != true && data.readOnly != true){
                        console.log('openScript data OK');
                        localStorage.setItem("openScript-"+submitEcid , Date.now());
                        // window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed);
                        console.log('SAVESCRIPT RESULT 1A localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                        window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed)
                        .then((data) => {
                            console.log('SAVESCRIPT RESULT DATA --> '+data);
                            if(data){
                                localStorage.removeItem("openScript-"+submitEcid);
                                console.log('SAVESCRIPT RESULT 1B localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                            }
                            console.log('SAVESCRIPT DONE');
                        });
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
                                message: 'Impossibile lavorare questo contatto. Verificare e riprovare',
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
    
                console.log('saveScriptLauncher openScript non eseguita perché già effettuata');
                console.log('saveScriptLauncher submitEcid --> '+submitEcid);
                console.log('saveScriptLauncher esito --> '+esito);
                // window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed);
                console.log('SAVESCRIPT RESULT 1A localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                window.TOOLBAR.EASYCIM.saveScript(submitEcid, esito, isResponsed)
                .then((data) => {
                    console.log('SAVESCRIPT RESULT DATA --> '+data);
                    if(data){
                        localStorage.removeItem("openScript-"+submitEcid);
                        console.log('SAVESCRIPT RESULT 1B localStorage.getItem("openScript-"'+submitEcid+') --> '+localStorage.getItem("openScript-"+submitEcid));
                    }
                    console.log('SAVESCRIPT DONE');
                });
                console.log('openScript value saved --> ',localStorage.getItem("openScript-"+submitEcid));
                console.log('SAVESCRIPT DONE');


            }
        }
        else{
    
            console.log('ecid non valorizzato');
        }
    }

    checkValidityOpenScript(){

        console.log('checkValidityOpenScript PUNTO 1');
        let ecidLoginTime;
        let submitEcid = this.ecid;
        console.log('checkValidityOpenScript PUNTO 2 --> submitEcid --> '+submitEcid);


        if(localStorage.getItem("openScript-"+submitEcid) != null){
            console.log('checkValidityOpenScript PUNTO 3'); 
            ecidLoginTime = localStorage.getItem("openScript-"+submitEcid);
            console.log('checkValidityOpenScript PUNTO 4 --> ecidLoginTime --> '+ecidLoginTime);
            console.log('checkValidityOpenScript PUNTO 5 --> this.firstLoginTime --> '+this.firstLoginTime);

            if(ecidLoginTime < this.firstLoginTime){
                console.log('checkValidityOpenScript PUNTO 6'); 
                localStorage.removeItem("openScript-"+submitEcid);
                return true;
            }
            else{
                console.log('checkValidityOpenScript PUNTO 7'); 
                return false;
            }
        }
        else{
            console.log('checkValidityOpenScript PUNTO 8'); 
            return true;
        }

    }

    @api async saveScript(esito, isResponsed) {
        console.log('---> ENTRATO IN SAVESCRIPT <---')
        window.TOOLBAR.EASYCIM.saveScript(await getCachedUuid(), esito, isResponsed);
    }
}