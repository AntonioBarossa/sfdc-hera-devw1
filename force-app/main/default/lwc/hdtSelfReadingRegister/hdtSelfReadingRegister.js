import { LightningElement, api, track, wire } from 'lwc';
import {refreshApex} from '@salesforce/apex';


export default class HdtSelfReadingRegister extends LightningElement {


    @api rowObj;
    @api commodity;
    @api isRetroactive;
    @api isVolture;
    @api isProcessReading;
    @api isVisible;
    @api allowSmallerReading = false;
    advanceError;

    get visibilityClass() {
        return this.isVisible === true ? 'slds-show' : 'slds-hide';
    }

    registerObjEle = [
        {id: 1, name: "readingType", label:"Tipo Lettura ", type: "text", value: null, disabled:true, visible:false},
        {id: 2, name: "readingDate", label:"Data Ultima Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id: 3, name: "readingOldValue", label:"Ultima Lettura ", type: "number", step:"0",value: null, disabled:true, visible:true},
        {id: 4, name: "readingValue", label:"Nuova Lettura ", type: "number", step:"0",value: null, disabled:false, visible:true},
        {id: 5, name: "readingBand", label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id: 6, name: "readingSerialNumber", label:"Matricola ", type: "text", value: null, disabled:true, visible:true},
        {id: 7, name: "readingUnit", label:"Unita di Misura", type: "text", value: null, disabled:true, visible:false},
        {id: 8, name: "readingRegister", label:"Registro", type: "text", value: null, disabled:true, visible:false},
        {id: 9, name: "readingDigitNumber", label:"Cifre Lettura", type: "text", value: null, disabled:true, visible:false}
    ];

    registerObjGas = [
        {id: 1, name: "readingDate", label:"Data Ultima Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id: 2, name: "readingOldValue", label:"Ultima Lettura ", type: "number", value: null, disabled:true, visible:true},
        {id: 3, name: "readingValue", label:"Nuova Lettura ", type: "number", value: null, disabled:false, visible:true},
        {id: 4, name: "readingSerialNumber", label:"Matricola ", type: "text", value: null, disabled:true, visible:true},
        {id: 5, name: "readingType", label:"Tipo ", type: "text", value: null, disabled:true, visible:false},
        {id: 6, name: "readingBand", label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id: 7, name: "readingRegister", label:"Registro", type: "text", value: null, disabled:true, visible:false},
        {id: 8, name: "readingUnit", label:"Unita di Misura", type: "text", value: null, disabled:true, visible:false},
        {id: 9, name: "readingDigitNumber", label:"Cifre Lettura", type: "text", value: null, disabled:true, visible:false}
    ];

    registerObjAcqua = [
        {id: 1, name: "readingDate", label:"Data Ultima Lettura ", type: "date", value: null, disabled:true, visible:true},
        {id: 2, name: "readingOldValue", label:"Ultima Lettura ", type: "number", value: null, disabled:true, visible:true},
        {id: 3, name: "readingValue", label:"Nuova Lettura ", type: "number", value: null, disabled:false, visible:true},
        {id: 4, name: "readingSerialNumber", label:"Matricola ", type: "text", value: null, disabled:true, visible:true},
        {id: 5, name: "readingType", label:"Tipo ", type: "text", value: null, disabled:true, visible:false},
        {id: 6, name: "readingBand", label:"Fascia ", type: "text", value: null, disabled:true, visible:false},
        {id: 7, name: "readingRegister", label:"Registro", type: "text", value: null, disabled:true, visible:false},
        {id: 8, name: "readingUnit", label:"Unita di Misura", type: "text", value: null, disabled:true, visible:false},
        {id: 9, name: "readingDigitNumber", label:"Cifre Lettura", type: "text", value: null, disabled:true, visible:false}
    ];

    @track registerObj = [];

    @track registerRet = [];
    



    connectedCallback(){

        this.registerObj = this.commodity === 'Energia Elettrica' ? this.registerObjEle : this.commodity === 'Gas' ? this.registerObjGas : this.registerObjAcqua;

        console.log('Register ' + this.rowObj.number);
        console.log('Register this.commodity' + this.commodity);
        console.log('Register length' + this.registerObj.length);
        
        if(this.commodity === 'Energia Elettrica'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){

                this.registerObj[i].label += 'F' + this.rowObj.headerIndex;
                console.log('### ' + this.rowObj.headerText + ' ' + this.registerObj[i].name);
                if(this.rowObj.headerText === 'Potenza' &&  (this.registerObj[i].name === 'readingValue' || this.registerObj[i].name === 'readingOldValue')){
                    console.log('###change step');
                    this.registerObj[i].step = "0.001";
                }

            }
        } else if(this.commodity === 'Gas' || this.commodity === 'Acqua'){

            for(let i=0; i<Object.keys(this.registerObj).length; ++i){
                if(this.registerObj[i].name === 'readingDate'
                || this.registerObj[i].name === 'readingSerialNumber'
                || this.registerObj[i].name === 'readingOldValue'
                || this.registerObj[i].name === 'readingValue'){

                    this.registerObj[i].label += this.rowObj.number;
                }

            }

        }

        // Per l'autolettura il tasto Verifica Ultima Lettura è obbligatorio, quindi inizialmente disabilitiamo tutto. 
        if (!this.isVolture) {
            for(let i=0; i<Object.keys(this.registerObj).length; ++i){
                if (this.registerObj[i].name === 'readingValue') {
                    this.registerObj[i].disabled = true;
                }
            }
        }

    }


    @api
    checkDate(readingCustomerDate){

        console.log('Method Called Correctly');

        console.log('isRetroactive? '+this.isRetroactive);

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        //today = dd + '/' + mm + '/' + yyyy;
        today = yyyy + '-' + mm + '-' + dd;

        if(Date.parse(readingCustomerDate) > Date.parse(today)){

            this.advanceError = 'Impossibile inserire una data futura!';

        }

        if(!this.isRetroactive && !this.isProcessReading){

            var index = this.registerObj.findIndex(p => p.name === 'readingDate');

            if(Date.parse(readingCustomerDate) <= Date.parse(this.registerObj[index].value)){

                this.advanceError = 'Impossibile inserire una data precedente o uguale all\'ultima lettura!'

            } else {

                this.advanceError = undefined;

            }

        }

        return this.advanceError;

    }

    @api
    handleLastReading(readingObj){

        console.log('Gestione lettura: ' + JSON.stringify(readingObj));
        console.log('rowObj: ' + JSON.stringify(this.rowObj));
        console.log('Object length >>> ' + readingObj.length);

        if (this.commodity === 'Energia Elettrica') {
            this.isVisible = (this.rowObj.id <= readingObj.length);
            var indexSerialNumberEle = this.registerObj.findIndex(p => p.name === 'readingSerialNumber');
            this.registerObj[indexSerialNumberEle].disabled = !this.isProcessReading;
        } else if (this.commodity === 'Gas') {
            this.isVisible = (this.rowObj.id === 'Meter' || (this.rowObj.id === 'Corrector' && readingObj.length >= 2));
        }else if(this.commodity === 'Acqua'){
            this.isVisible = true;
        }
        console.log('IsVisible >>> ' + this.isVisible);

        
        // Per l'autolettura da processo la matricola deve poter essere inseribile da operatore.
        if (this.isVisible === true) {
            var indexSerialNumber = this.registerObj.findIndex(p => p.name === 'readingSerialNumber');
            this.registerObj[indexSerialNumber].disabled = !this.isProcessReading;
        }

        var indexIn = readingObj.findIndex(p => p.register == this.rowObj.number);

        console.log('indexIn: ' + indexIn);

        if(indexIn == -1){

            var indexCustomerReading = this.registerObj.findIndex(p => p.name === 'readingValue');

            this.registerObj[indexCustomerReading].disabled = true;

        } else{
            if (!this.isVolture) {
                var indexCustomerReading = this.registerObj.findIndex(p => p.name === 'readingValue');
                this.registerObj[indexCustomerReading].disabled = false;
            }

            for(const property in readingObj[indexIn]){

                console.log(property);

                var indexOut = this.registerObj.findIndex(p => {

                    /*if(property == "Lettura"){

                        return this.commodity === "Energia Elettrica" ? p.label == property+' '+this.rowObj.number 
                        : this.commodity === "Gas" ? p.label == property 
                        : null;

                    } else{

                        return p.label.includes(property);

                    }*/
                    
                    return p.name === property;

                });

                console.log("indexOut "+indexOut);

                if(indexOut >= 0){

                    console.log(readingObj[indexIn][property]);

                    this.registerObj[indexOut].value = readingObj[indexIn][property];

                    console.log(this.registerObj);
                
                }          
            }
        }
    }

    @api oldReadingValue(){
        const parsedValue = parseInt(this.registerObj[this.registerObj.findIndex(p => p.name === 'readingOldValue')].value);
        return isNaN(parsedValue) ? 0 : parsedValue;
    }

    @api newReadingValue(){
        const parsedValue = parseInt(this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value);
        return isNaN(parsedValue) ? 0 : parsedValue;
    }

    @api
    handleSave(readingCustomerDate, object ){

        console.log('#Object >>> ' + JSON.stringify(object));
        try {
            if (!this.isProcessReading){
                console.log('#RegisterObj >>> ' + JSON.stringify(this.registerObj));
                this.registerObj.forEach(element => {
                    if( ( object === 'case'  || (object === 'Order' && this.isVolture) ) && 
                        element.disabled == false && (element.value == null || element.value == '' || element.value == undefined)){
                        this.advanceError = 'Impossibile procedere: Nuova Lettura deve essere valorizzata.';
                    } 
                });
            } else if (this.rowObj.id === 'Meter' || (this.isVisible && this.commodity === 'Energia Elettrica')) {
                // Per l'autolettura da processo GAS richiediamo le obbligatorietà solo sul registro del Misuratore, poichè non sappiamo a priori se c'è anche un Correttore.
                this.registerObj.forEach(element => {
                    if(element.disabled == false && (element.value == null || element.value == '' || element.value == undefined)){
                        this.advanceError = 'Impossibile procedere: il campo ' + element.label + ' deve essere valorizzato.';
                    }
                });
            }

            const oldValue = parseInt(this.registerObj[this.registerObj.findIndex(p => p.name === 'readingOldValue')].value);
            const newValue = parseInt(this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value);
            console.log(newValue + ' ' + ' ' + this.rowObj.headerText);
            if (this.allowSmallerReading === false && newValue < oldValue && this.rowObj.headerText != 'Potenza') {
                this.advanceError = 'Impossibile inserire una lettura inferiore alla precedente.';
            }
    
            console.log('advanceError: ' + this.advanceError);
    
            if(this.advanceError != undefined){
    
                return this.advanceError;
    
            } else{
    
                console.log('Filling the Array: ' + JSON.stringify(this.registerObj) + ' - ' + JSON.stringify( this.rowObj));
                let readingDateNew = this.isVisible ? readingCustomerDate : null;

                this.registerRet = 
                    {
                        ['ReadingDate'+this.rowObj.id+'__c']:readingDateNew, // usiamo la data lettura cliente su tutti i registri visibili.
                        ['ReadingType'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingType')].value,
                        ['ReadingBand'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingBand')].value,
                        ['ReadingSerialNumber'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingSerialNumber')].value,
                        ['ReadingValue'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value,
                        ['ReadingOldValue'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingOldValue')].value,
                        ['ReadingRegister'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingRegister')].value,
                        ['ReadingUnit'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingUnit')].value,
                        ['ReadingDigitNumber'+this.rowObj.id+'__c']:this.registerObj[this.registerObj.findIndex(p => p.name === 'readingDigitNumber')].value
                    };
    
                    console.log('Array filled with: ' + this.registerRet + ' keys: ' + Object.keys(this.registerRet));
    
                    return this.registerRet;
    
            }
        } catch (e) {
            console.log('exception ' + e);
            throw e;
        }

    }


    handleChange(event){

        console.log(event.target.label);

        console.log(event.target.value);

        console.log('isRetroactive? '+this.isRetroactive);

        if(event.target.label.includes('Nuova Lettura') && !this.isRetroactive && !this.isProcessReading){
            
            var indexReading = this.registerObj.findIndex(p => {

                return p.name === 'readingOldValue';

            });

            const previousReading = this.registerObj[indexReading].value;
            const newReading = event.target.value;

            // Mostriamo l'errore solo dopo che l'operatore inserisce almeno lo stesso numero di cifre della vecchia lettura. 
            console.log(newReading + ' ' + previousReading +' ' + this.rowObj.headerText);
            if(this.allowSmallerReading === false && newReading.length >= previousReading.length && parseInt(newReading) < parseInt(previousReading) && this.rowObj.headerText != 'Potenza'){

                this.advanceError = 'Impossibile inserire lettura inferiore all\'ultima lettura';

                event.target.setCustomValidity(this.advanceError);

            }else if(event.target.value > 99999999999){

                this.advanceError = 'Valore lettura troppo elevato';

                event.target.setCustomValidity(this.advanceError);

            } else {

                this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value = event.target.value; 

                this.advanceError = undefined;

                event.target.setCustomValidity("");

            }

        } else {
            if (event.target.label.includes('Lettura')) {
                this.registerObj[this.registerObj.findIndex(p => p.name === 'readingValue')].value = event.target.value;
            } else if (event.target.label.includes('Matricola')) {
                this.registerObj[this.registerObj.findIndex(p => p.name === 'readingSerialNumber')].value = event.target.value;
            }

            this.advanceError = undefined;
            event.target.setCustomValidity("");
        }

        event.target.reportValidity();


    }

}