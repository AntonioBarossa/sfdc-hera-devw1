import { LightningElement, track, api } from 'lwc';
import updateSelfReading from '@salesforce/apex/HDT_LC_SelfReading.updateSelfReading';

//fare metodo per showtoast

export default class HdtSelfReading extends LightningElement {

    @api commodity;

    selfReadingObj = [];

    rowObj = []

    outputObj = [];

    rowNumber;

    lastReading;

    buttonDisabled = false;

    advanceError = undefined;

    errorAdvanceMessage = 'Impossibile salvare autolettura. Si prega di correggere gli errori';

    @track readingCustomerDate;

    connectedCallback(){

        this.rowNumber = this.commodity === 'Energia Elettrica' ? 9 : this.commodity === 'Gas' ? 2 : 0;

        if(this.commodity === 'Energia Elettrica'){

            console.log('loop energia elettrica')

            for(let i=1; i <= this.rowNumber; ++i){

                this.rowObj = [...this.rowObj,{id:i, number: i}];
    
            }    

        } else if(this.commodity === 'Gas'){

            console.log('loop gas');

            this.rowObj = [...this.rowObj,{id:1, number: "Misuratore"},{id:2, number: "Correttore"}];


        }


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
    
    handleClick(){

        this.buttonDisabled = true;

        if(this.commodity == 'Energia Elettrica'){

            this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                element.handleLastReading('[{"register":"1", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F1","Matricola":"R00100000002956134", "Lettura":"1620"},{"register":"2", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F2","Matricola":"R00100000002956134", "Lettura":"1390"},{"register":"3", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F3","Matricola":"R00100000002956134", "Lettura":"1410"},{"register":"4", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F4","Matricola":"R00100000002956134", "Lettura":"1203"},{"register":"5", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F5","Matricola":"R00100000002956134", "Lettura":"1041"},{"register":"6", "Tipo Lettura":"Multi Reg. Attiva", "Data Lettura":"2021-01-20", "Fascia":"F6","Matricola":"R00100000002956134", "Lettura":"1508"}]');

            });

        } else if(this.commodity == 'Gas'){

            this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                element.handleLastReading('[{"register":"Misuratore", "Tipo":"Volumetrico","Mat.":"R00050030408819956","Fascia":"M1","Registro":"001","Data Lettura":"2021-02-11","Lettura":"3000","Unita di Misura":"M3"}]');

            });

        }

    }

    handleSaveButton(){

        if(this.advanceError != undefined){

            console.log(this.errorAdvanceMessage);

            return;

        } else if(this.readingCustomerDate == null || this.readingCustomerDate == undefined){

            this.errorAdvanceMessage = 'Impossibile procedere: Valorizzare Data Lettura Cliente';

            console.log(this.errorAdvanceMessage);

            return;

        } else {

            try{this.template.querySelectorAll('c-hdt-self-reading-register').forEach(element =>{

                var result = element.handleSave();

                if(String(result).includes("Impossibile")){

                    this.errorAdvanceMessage = result;

                    console.log(this.errorAdvanceMessage);

                    this.outputObj = [];

                    throw BreakException;

                }

                console.log(result);

                this.outputObj.push(result);

            });

        } catch (e) { 

            if (e !== BreakException){

                this.outputObj = [];

                throw e;

            } ;

            }
        }

        console.log(JSON.stringify(this.outputObj));

        updateSelfReading({fields : JSON.stringify(this.outputObj), 
            readingCustomerDate:String(this.readingCustomerDate),
            commodity:this.commodity})
        .then(result => { console.log(result) })
        .catch(error => { console.log(error) });



    }


    /*reverseDate(inputDate){

        var date = new Date(inputDate);

        var dd = String(date.getDate()).padStart(2, '0');
        var mm = String(date.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = date.getFullYear();

        date = dd + '/' + mm + '/' + yyyy;

        return date;


    }*/




}