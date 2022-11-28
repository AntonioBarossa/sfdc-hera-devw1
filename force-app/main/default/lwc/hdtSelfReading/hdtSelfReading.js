import { LightningElement, track, api, wire } from 'lwc';
import insertSelfReading from '@salesforce/apex/HDT_LC_SelfReading.insertSelfReading';
import updateSelfReading from '@salesforce/apex/HDT_LC_SelfReading.updateSelfReading';
import getReadingId from '@salesforce/apex/HDT_LC_SelfReading.getReadingId';
import getRecordTypeId from '@salesforce/apex/HDT_LC_SelfReading.getRecordTypeId';
import checkLastReadings from '@salesforce/apex/HDT_LC_SelfReading.checkLastReadings';
import {FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    {
        label: 'Lettura Inseribile Dal',
        fieldName: 'startWindowDate',
        type: 'date', 
        typeAttributes: { year: "numeric", month: "long", day: "2-digit" }, 
        cellAttributes: { class: { fieldName: 'windowClass' } } 
    },
    {
        label: 'Lettura Inseribile Fino Al',
        fieldName: 'endWindowDate',
        type: 'date',
        typeAttributes: { year: "numeric", month: "long", day: "2-digit" },
        cellAttributes: { class: { fieldName: 'windowClass' } }
    }
];

export default class HdtSelfReading extends LightningElement {

    @api commodity;
    @api recordId;
    @api object;
    @api servicePointId;
    @api isVolture;
    @api isRetroactive;
    @api isProcessReading;
    @api availableActions = [];
    @api saveDraft;
    @api cancelCase;
    @api nextLabel;
    @api nextVariant;
    @api resumedFromDraft;
    @api showDraftButton;
    @api showBackButton;
    @api showCancelButton;
    @api readingCustomerDate;
    @api disabledReadingDate;
    @api isSaved = false;
    @api allowSmallerReading = false;
    @api oldTotalReadingValue;
    @api newTotalReadingValue;
    @api selectedReadingValue;
    @api selectedReadingsList;
    @api isRettificaConsumi;
    @api tipizzazioneRettificaConsumi;
    @api showReadingWindows;
    @api isMono;

    @track isLoading = false;
    @track windowColumns;
    @track readingWindows = [];
    @track showWindowsModal = false;

    recordKey;
    selfReadingObj = [];
    rowObj = []
    outputObj = {};
    rowNumber;
    lastReading;
    buttonDisabled = false;
    advanceError = undefined;
    recordTypeId;
    errorAdvanceMessage = '';
    lastReadingsChecked = false;

    hideModal(){
        this.showWindowsModal = false;
    }

    showModal(){
        this.showWindowsModal = true;
    }

    get hasReadingWindows(){
        return this.readingWindows.length > 0;
    }

    connectedCallback(){

        if (this.selectedReadingsList != undefined) {
            console.log('selectedReadingsList: ' + this.selectedReadingsList);
            this.selectedReadingsList = JSON.parse(this.selectedReadingsList);
        }

        this.windowColumns = columns;
        this.oldTotalReadingValue = 0;
        this.newTotalReadingValue = 0;
        this.readingCustomerDate = this.sysdate();

        this.recordKey = this.object === 'Order' ? 
            (this.commodity === 'Energia Elettrica' ? 'OrderEle__c' : (this.commodity === 'Gas' ? 'OrderGas__c' : 'OrderAcqua__c')) : 
            (this.commodity === 'Energia Elettrica' ? 'CaseEle__c' : (this.commodity === 'Gas' ? 'CaseGas__c' : 'CaseAcqua__c'));

        this.rowNumber = this.commodity === 'Energia Elettrica' ? 9 : this.commodity === 'Gas' ? 2 : 1;

        if(this.commodity === 'Energia Elettrica'){

            console.log('loop energia elettrica')

            for(let i=1; i <= this.rowNumber; ++i){
                const headerText = i <= 3 ? 'Energia Attiva' : (i <= 6 ? 'Energia Reattiva' : 'Potenza');
                const headerIndex = i % 3 == 0 ? 3 : i % 3;  // L'indice è sempre 1, 2, o 3.
                this.rowObj = [...this.rowObj,{id:i, number: i, headerText: headerText, headerIndex: headerIndex}];
            }    
        } else if(this.commodity === 'Gas' ){
            console.log('loop gas');
            this.rowObj = [...this.rowObj,{id:'Meter', number: "Misuratore", headerText: "Misuratore"},{id:'Corrector', number: "Correttore", headerText: "Correttore"}];
        } else if(this.commodity === 'Acqua' ){
            console.log('loop acqua');
            this.rowObj = [...this.rowObj,{id:'Meter', number: "Misuratore", headerText: "Misuratore"}];
        }

        getRecordTypeId({commodity:this.commodity})
        .then(result =>{

            this.recordTypeId = result;
            this.callLastReadings();

        }).catch(errror =>{

            console.log(error);

        });


    }


    handleDateChange(event){

        this.readingCustomerDate = event.target.value;

        console.log(event.target.value);

        var result = this.template.querySelector('c-hdt-self-reading-register').checkDate(event.target.value)

        console.log('Call result: '+result);

        if(result != undefined){

            event.target.setCustomValidity(result);

            this.advanceError = result;

        } else {

            this.advanceError = undefined;

            event.target.setCustomValidity("");

        }

        event.target.reportValidity();

        console.log('methodCalled');

        console.log('Check Error status '+this.advanceError);

    }

    callLastReadings(){

        console.log('Chiamata a WS Verifica Ultima Lettura');
        this.buttonDisabled = true;
        this.isLoading = true;
        this.lastReadingsChecked = true;

        checkLastReadings({servicePointId:this.servicePointId})
        .then(result =>{
            let lastReadings = [];
            console.log('checkLastReadings results: ' + result);
            if (result == null) {
                this.isLoading = false;
                this.buttonDisabled = false;
                this.errorAdvanceMessage = 'Errore di sistema, impossibile recuperare le ultime letture. Contattare un amministratore di sistema.';
                this.showToastMessage(this.errorAdvanceMessage);
                return;
            }
            if (result === 'ERROR_NO_ASSET_NUMBER') {
                lastReadings = this.emptyArrayAutoletturaDaProcesso();
            } else {
                const parsedResult = JSON.parse(result);
                // Verifichiamo se la response contiene un errore da SAP.
                if ("errorDetails" in parsedResult && "message" in parsedResult.errorDetails[0]) {
                    this.isLoading = false;
                    this.buttonDisabled = false;
                    this.errorAdvanceMessage = 'Errore da SAP: ' + parsedResult.errorDetails[0].message;
                    this.showToastMessage(this.errorAdvanceMessage);
                    return;
                }
                lastReadings = this.fillLastReadingsArray(parsedResult);
            }
            this.isLoading = false;
            console.log('isLoading?: ' + this.isLoading);
            console.log('filled obj: ' + JSON.stringify( lastReadings));
            console.log('querySelectorAll #: ' + this.template.querySelectorAll('c-hdt-self-reading-register').length);

            if(this.commodity == 'Energia Elettrica'){
                this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{
                    element.handleLastReading(lastReadings);
                    //element.handleLastReading('[{"register":"1", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F1","readingSerialNumber":"R00100000002956134", "readingOldValue":"1620"},{"register":"2", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F2","readingSerialNumber":"R00100000002956134", "readingOldValue":"1390"},{"register":"3", "readingType":"Multi Reg. Attiva", "readingDate":"2021-01-20", "readingBand":"F3","readingSerialNumber":"R00100000002956134", "readingOldValue":"1410"}]');
                });
            } else if(this.commodity == 'Gas' || this.commodity == 'Acqua'){
                this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{
                    element.handleLastReading(lastReadings);
                    //element.handleLastReading('[{"register":"Misuratore", "readingType":"Volumetrico","readingSerialNumber":"R00050030408819956","readingBand":"M1","readingRegister":"001","readingDate":"2021-02-11","readingOldValue":"3000","readingUnit":"M3"},{"register":"Correttore", "readingType":"Volumetrico","readingSerialNumber":"R00050030408819956","readingBand":"M1","readingRegister":"001","readingDate":"2021-02-11","readingOldValue":"3000","readingUnit":"M3"}]');
                });
            }

        }).catch(error =>{
            this.isLoading = false;
            this.buttonDisabled = false;
            console.log('checkLastReadings failed: ' + error);
        });
    }
    
    @api
    handleClick(){

        this.callLastReadings();

    }

    // Per le autoletture da processo che non possono richiamare il VerificaUltimaLettura creiamo degli array vuoti.
    // Assumiamo come default 3 registri per l'ELE e uno solo per il GAS.
    emptyArrayAutoletturaDaProcesso(){
        let emptyRegisters = [];

        if (this.commodity === 'Energia Elettrica') {
            for (let i = 1; i <= 3; i++) {
                emptyRegisters.push({
                    register: i,
                    readingType: null,
                    readingSerialNumber: null,
                    readingDate: null,
                    readingOldValue: null,
                    readingUnit: null,
                    readingRegister: null,
                    readingDigitNumber: null
                });
            }
        } else if (this.commodity === 'Gas'){
            emptyRegisters.push({
                register: 'Misuratore',
                readingType: null,
                readingSerialNumber: null,
                readingDate: null,
                readingOldValue: null,
                readingUnit: null,
                readingRegister: null,
                readingDigitNumber: null
            });
            emptyRegisters.push({
                register: 'Correttore',
                readingType: null,
                readingSerialNumber: null,
                readingDate: null,
                readingOldValue: null,
                readingUnit: null,
                readingRegister: null,
                readingDigitNumber: null
            });
        }else{
            emptyRegisters.push({
                register: 'Misuratore',
                readingType: null,
                readingSerialNumber: null,
                readingDate: null,
                readingOldValue: null,
                readingUnit: null,
                readingRegister: null,
                readingDigitNumber: null
            });
        }

        return emptyRegisters;
    }





    /**
     * Effettua il parsing del JSON della response del WS di Verifica Ultima Lettura,
     * restituendo l'array di registri valorizzato.
     */
    fillLastReadingsArray(lastReadingsResponse){

        const lastReadings = lastReadingsResponse.data;

        if ('intervalloFatturazione' in lastReadings) {
            try {
                let windows = lastReadings['intervalloFatturazione'];
                // SAP manda le date nel formate DD/MM/YYYY, effettuiamo il parsing per ottenere oggetti Date
                let dateWindows = [];
                windows.forEach(window => {
                    let splittedFromDate = window.dataDa.split('/');
                    let splittedToDate = window.dataA.split('/');
                    let dateFrom = new Date(parseInt(splittedFromDate[2], 10), parseInt(splittedFromDate[1], 10) - 1, parseInt(splittedFromDate[0], 10));
                    let dateTo = new Date(parseInt(splittedToDate[2], 10), parseInt(splittedToDate[1], 10) - 1, parseInt(splittedToDate[0], 10));
                    let today = new Date();
                    let dateClass = today >= dateFrom && today <= dateTo ? 'slds-text-color_success' : 'slds-text-color_error';
                    dateWindows.push({
                        startWindowDate: dateFrom,
                        endWindowDate: dateTo,
                        windowClass: dateClass
                    });
                });
                console.log('reading windows: ' + JSON.stringify(dateWindows));
                this.readingWindows = dateWindows;
            } catch (e) {
                console.log('error parsing dates: ' + e);
            }
        }

        let registers = [];
        let finalRegisters = []
        let isBiorario = false;

        try {
            for (const key in lastReadings) {
                console.log('processing key: ' + key + ' with value: ' + lastReadings[key]);
                const match = key.match(/\d+/);
                const index = match ? match[0] : -1;

                if (index < 0) {
                    continue;
                }

                const i = index - 1; // Indice effettivo, la response inizia da 1 anzichè da 0.
                if (registers[i] === undefined) {
                    registers[i] = {};
                }

                if (this.commodity === 'Energia Elettrica') {
                    registers[i].register = index;
                } else {
                    const gasIndex = index === '1' ? 'Misuratore' : 'Correttore';
                    registers[i].register = gasIndex;
                }

                console.log('index: ' + i);
                if (key.startsWith('herTipologiaMisuratore')) {
                    registers[i].readingType = lastReadings[key];
                } else if (key.startsWith('herMatricolaMisuratore')) {
                    registers[i].readingSerialNumber = lastReadings[key];
                } else if (key.startsWith('herDataLettura')) {
                    const readingDate = lastReadings[key];
                    // La response di SAP valorizza la data lettura a null/vuota se il registro non ha una lettura
                    // Skippiamo questa key in modo da marcare l'oggetto del registro come 'da rimuovere'
                    if (readingDate === null || readingDate.length === 0) {
                        continue;
                    }
                    registers[i].readingDate = this.convertItalianDate(readingDate);
                } else if (key.startsWith('herFascia')) {
                    registers[i].readingBand = lastReadings[key];
                } else if (key.startsWith('herLettura') && lastReadings[key] != null) {
                    let reading = lastReadings[key];
                    reading = reading.split('.').join('');  // rimuoviamo il separatore delle migliaia per poter parsare come int.
                    reading = reading.replace(/,/g, '.');
                    registers[i].readingOldValue = reading;
                } else if (key.startsWith('herUnitaDiMisura')) {
                    registers[i].readingUnit = lastReadings[key];
                } else if (key.startsWith('herRegistro')) {
                    registers[i].readingRegister = lastReadings[key];
                } else if (key.startsWith('herCifrePrecedentiLaVirgola')) {
                    registers[i].readingDigitNumber = lastReadings[key];
                }
            }

            registers.forEach(register => {
                // Lasciamo solo i registri che hanno una lettura, ovvero quelli che hanno la property readingDate.
                if ('readingDate' in register) {
                    finalRegisters.push(register);
                    
                    // Se la response contiene almeno un registro con banda=F1|F2|F3, vuol dire che l'impianto supporta letture bi-orarie.
                    // Diversmente assumiamo che l'impianto è mono-orario (tutti i registri valorizzati dovrebbero avere banda=M)
                    if (this.commodity === 'Energia Elettrica' && register.readingBand != null && register.readingBand.startsWith('F')) {
                        console.log('lettura bi-oraria');
                        isBiorario = true;
                    }
                }
            });
        } catch (error) {
        console.error(error);
        }

        if (this.commodity === 'Energia Elettrica') {
            this.isMono = !isBiorario;
            console.log('mono orario? ' + this.isMono);
        }

        return finalRegisters;
    }

    // event è definito solo per la voltura (this.isVolture) 
    @api
    handleSaveButton(){    

        console.log('Inside Reading Method');

        //console.log('handleSaveButton ' + event + ' is saved?' + this.isSaved);

        /*if(this.isVolture && event != undefined && event.target.name === 'previous'){

            let dispObj = {name: event.target.name};

            this.dispatchEvent(new CustomEvent('savereading', {detail: dispObj}));

            return;

        }*/


        if(this.advanceError != undefined){

            console.log(this.errorAdvanceMessage);

            return;

        } else if(this.readingCustomerDate == null || this.readingCustomerDate == undefined){

            this.errorAdvanceMessage = 'Impossibile procedere: Valorizzare Data Lettura Cliente';

            this.showToastMessage(this.errorAdvanceMessage);

            console.log(this.errorAdvanceMessage);

            throw BreakException;

        } else if(!this.isVolture && !this.lastReadingsChecked){
            this.errorAdvanceMessage = 'Premere il pulsante Verifica Ultima Lettura ed inserire le letture del cliente.';

            this.showToastMessage(this.errorAdvanceMessage);

            console.log(this.errorAdvanceMessage);

            throw BreakException;
        } else {

            try{
                const registers = this.template.querySelectorAll('c-hdt-self-reading-register');
                console.log('#registri: ' + registers.length);


                let numeroRegistriStimati = 0; // contatore per tipizzare come Errore Stima Consumi
                let numeroRegistriErrati= 0;   // contatore per tipizzare come Errore di Lettura
                let numeroRegistriAlert = 0;   // contatore per alert bloccante.

                for (let i = 0; i < registers.length; i++) {
                    let register = registers[i];

                    let result = register.handleSave(this.readingCustomerDate);

                    if(String(result).includes("Impossibile")){
                        this.errorAdvanceMessage = result;
                        console.log('Error '+this.errorAdvanceMessage);
                        this.outputObj = {};
                        this.showToastMessage(this.errorAdvanceMessage);
                        throw BreakException;
                    }

                    console.log('registro # ' + i + ': ' + result);

                    const oldReadingValue = register.oldReadingValue();
                    const newReadingValue = register.newReadingValue();
                    const selectedReadingValue = this.findSelectedReading(i);

                    console.log('lettura precedente a sistema: ' + oldReadingValue)
                    console.log('lettura comunicata dal cliente: ' + newReadingValue)
                    console.log('lettura selezionata da cruscotto letture: ' + selectedReadingValue);

                    if (this.isRettificaConsumi === true && newReadingValue > 0 && oldReadingValue >= 0) {  // newReadingValue > 0 && oldReadingValue >= 0 per skippare i registri nascosti
                        if (selectedReadingValue > 0) {
                            if (newReadingValue > oldReadingValue && newReadingValue > selectedReadingValue) {
                                numeroRegistriAlert++;
                            } else if (newReadingValue > oldReadingValue && newReadingValue < selectedReadingValue) {
                                numeroRegistriStimati++;
                            }
                        } else {
                            if (newReadingValue < oldReadingValue) {
                                numeroRegistriErrati++;
                            } else if (newReadingValue > oldReadingValue) {
                                numeroRegistriAlert++;
                            }
                        } 
                    }

                    for(const [key,value] of Object.entries(result)){

                        this.outputObj[`${key}`] = value;

                    }

                    console.log('OutputObj '+this.outputObj);

                }

                if (this.isRettificaConsumi === true) {
                    console.log('numeroRegistriErrati: ' + numeroRegistriErrati);
                    console.log('numeroRegistriStimati: ' + numeroRegistriStimati);
                    console.log('numeroRegistriAlert: ' + numeroRegistriAlert);
                    if (numeroRegistriAlert > 0 && numeroRegistriErrati === 0 && numeroRegistriStimati === 0) {
                        console.log('Alert per verificare necessità di autolettura.');
                        this.errorAdvanceMessage = 'Verificare la lettura inserita. Se la lettura risulta corretta, è necessario annullare questo Case e proseguire con una Autolettura.';
                        this.showToastMessage(this.errorAdvanceMessage);
                        throw BreakException;
                    } else if (numeroRegistriStimati > 0 && numeroRegistriErrati === 0 && numeroRegistriAlert === 0) {
                        this.tipizzazioneRettificaConsumi = 'Errore Stima Consumi';
                    } else {
                        this.tipizzazioneRettificaConsumi = 'Errore di Lettura';
                    }
                }

                console.log('tipizzazioneRettificaConsumi: ' + this.tipizzazioneRettificaConsumi);

            } catch (e) { 

                if (e !== BreakException){

                    console.log('exception: ' + e);
                    this.outputObj = {};

                    throw e;

                } ;

            }
        }

        this.outputObj['ReadingDate__c'] = this.readingCustomerDate;

        this.outputObj[`${this.recordKey}`] = this.recordId;

        this.outputObj['Name'] = 'Lettura ' + this.currentDateTime();

        this.outputObj['RecordTypeId'] = this.recordTypeId;

        if (this.resumedFromDraft === true) {
            console.log('Resumed from draft');

            getReadingId({
                objectName : this.object,
                objectId : this.recordId,
                commodity : this.commodity
            })
            .then(result => { 
                
                console.log('getReadingId result ' + result);
                if (result != null && result != undefined) {

                    this.outputObj['Id'] = result;

                    if (!this.isSaved) {
                        console.log('Update record oggetto Reading__c esistente: ' + this.outputObj['Id']);
                        updateSelfReading({fields : JSON.stringify(this.outputObj)})
                        .then(result => { 
                                       
                            this.isSaved = true;
                        
                        })
                        .catch(error => { console.log(error) });
                    }
                }else{ 
                    //gestione creazione record Reading__c al Riprendi Case da Bozza, in questo caso infatti non è presente il record di Reading e va creato
                    if(!this.isSaved && this.resumedFromDraft && this.object === 'case'){
                        console.log('Inserimento nuovo record oggetto Reading__c');
                        insertSelfReading({fields : JSON.stringify(this.outputObj)})
                        .then(result => { 
                            
                            this.isSaved = true;
                        
                        })
                        .catch(error => { console.log(error) });
                    }
                }
            })
            .catch(error => { console.log(error) });
        }

        //this.outputObj[`${commodity === 'Energia Elettrica' ? 'OrderElectricEnergy__c' : 'OrderGas__c'}`] = this.recordId

        console.log('stringify: ' + JSON.stringify(this.outputObj));

        if(!this.isSaved && !this.resumedFromDraft){

            console.log('Inserimento nuovo record oggetto Reading__c');
            insertSelfReading({fields : JSON.stringify(this.outputObj)})
            .then(result => { 
                
                this.isSaved = true;
            
            })
            .catch(error => { console.log(error) });

        } else {

            if(this.isVolture && this.resumedFromDraft === false){            
                
                let errorVolture = 'Autolettura già inserita';

                this.showToastMessage(errorVolture);
            
            }

        }
    }

    findSelectedReading(index) {
        if (this.selectedReadingsList === undefined) {
            return 0;
        }
        let fascia = '';
        if (this.commodity === 'Energia Elettrica') {
            fascia = 'Fascia ' + (index + 1);
        } else {
            fascia = 'Monofascia'; // TODO: verificare se per il Correttore c'è altro.
        }

        for (let i = 0; i < this.selectedReadingsList.length; i++) {
            let selectedReading = this.selectedReadingsList[i];
            console.log('fascia: ' + fascia + ' selectedReading: ' + JSON.stringify( selectedReading));
            if (selectedReading['tipoNumeratore'] === fascia) {
                let parsedValue = parseInt(selectedReading['posizioniPrecedentiLaVirgola']);
                return isNaN(parsedValue) ? 0 : parsedValue;
            }
        }

        return 0;
    }

    handleNavigation(event){

        const action = event.detail;
        console.log('handleNavigation ' + action);

        if(action === 'next' || action === 'draft' || action === 'save'){

            this.saveDraft = action === 'draft'; 
            this.cancelCase = false;

            if(this.availableActions.find(action => action === 'NEXT')){

                try {
                    this.handleSaveButton();
                } catch (e) {
                    console.log('handleNavigation catch' + e);
                    this.showToastMessage(this.errorAdvanceMessage);
                    this.errorAdvanceMessage = '';
                    return;
                }

                const navigateNextEvent = new FlowNavigationNextEvent();
    
                this.dispatchEvent(navigateNextEvent);
    
            } else {

                try {
                    this.handleSaveButton();
                } catch (e) {
                    console.log('handleNavigation catch' + e);
                    this.showToastMessage(this.errorAdvanceMessage);
                    this.errorAdvanceMessage = '';
                    return;
                }

                const navigateFinish = new FlowNavigationFinishEvent();
    
                this.dispatchEvent(navigateFinish);
            }

        } else if(action === 'previous'){

            const navigateBackEvent = new FlowNavigationBackEvent();

            this.dispatchEvent(navigateBackEvent);
    
        } else if(action === 'cancel'){

            this.cancelCase = true;

            if(this.availableActions.find(action => action === 'NEXT')){

                const navigateNextEvent = new FlowNavigationNextEvent();
    
                this.dispatchEvent(navigateNextEvent);
    
            } else {
    
                const navigateFinish = new FlowNavigationFinishEvent();
    
                this.dispatchEvent(navigateFinish);
            }

        }

    }

    showToastMessage(errorMessage){

        const toastErrorMessage = new ShowToastEvent({
            title: 'Errore',
            message: errorMessage,
            variant: 'error',
        });
        this.dispatchEvent(toastErrorMessage);


    }

    // Genera la sysdate in formato DD/MM/YYYY HH:MM
    currentDateTime(){
        const today = new Date();
        const dateOptions = { day: '2-digit', month: '2-digit', year: 'numeric' };
        const timeOptions = { hour12: false, hour: '2-digit', minute:'2-digit' };

        // Usiamo en-GB per forzare il formato con gli slash (DD/MM/YYYY)
        return today.toLocaleString('en-GB', dateOptions) + ' ' + today.toLocaleTimeString('en-GB', timeOptions);
    }

    sysdate(){
        var sysdateIso = new Date().toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return sysdateIso.substr(0, sysdateIso.indexOf('T'));
    }

    convertItalianDate(italianDate){
        var parts = italianDate.split("/");
        var date = new Date(parseInt(parts[2], 10),
                            parseInt(parts[1], 10) - 1,
                            parseInt(parts[0], 10));

        var dateIso = date.toISOString(); // Es: 2021-03-01T15:34:47.987Z
        return dateIso.substr(0, dateIso.indexOf('T'));
    }

    reverseDate(inputDate){

        var date = new Date(inputDate);

        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = date.getFullYear();

        date = dd + '/' + mm + '/' + yyyy;

        return date;


    }




}