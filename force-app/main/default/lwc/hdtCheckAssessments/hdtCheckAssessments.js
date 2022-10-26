import { LightningElement, api, track } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import handleSearch from '@salesforce/apex/HDT_LC_CheckAssessments.handleSearch';

const columns = [ { label: 'Nr. Atto', fieldName: 'NrAtto',  sortable: "true"}, //OK
                  { label: 'Data Atto', fieldName: 'DataAtto', sortable: "true"},
                  { label: 'Tipo Tributo', fieldName: 'TipoTributo'},
                  { label: 'Accertamento per', fieldName: 'AccertamentoPer' },
                  { label: 'Stato', fieldName: 'Stato' },
                  { label: 'Base Dati', fieldName: 'BaseDati'},
                  { label: 'Data Inizio', fieldName: 'DataInizio', sortable: "true"},
                  { label: 'Data Fine', fieldName: 'DataFine' },
                  { label: 'Soggetto', fieldName: 'Soggetto'},
                  { label: 'Indirizzo', fieldName: 'Indirizzo'},
                  { label: 'Civico', fieldName: 'Civico'},
                  { label: 'Contratto', fieldName: 'Contratto'},
                  { label: 'Superficie Accertata', fieldName: 'SuperficieAccertata'},
                  { label: 'Categoria Accertata', fieldName: 'CategoriaAccertata'}];


function equalsIgnoreCase(str1, str2){
    return typeof str1 === 'string' && typeof str2 === 'string'? 
                str1.localeCompare(str2, undefined, { sensitivity: 'accent' }) === 0
                : str1 === str2;
}

export default class HdtCheckAssessments extends LightningElement {
    @api fiscalCode;
    @api 
    get supplyCity(){
        return this._supplyCityCode?.slice(-5);
    }
    set supplyCity(value){
        this._supplyCityCode=value;
    }
    @api 
    get customerMarking(){
        return equalsIgnoreCase(this._customerMarking, "Persona Fisica")? "F" : "G";
    }
    set customerMarking(value){
        this._customerMarking=value;
    }
    @track data;
    _supplyCityCode;
    _customerMarking;
    columns = columns;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }


    connectedCallback(){
        console.log('CallBack start');

        handleSearch({
            cfPiva : this.fiscalCode,
            comuneFornitura : this.supplyCity,
            tipoPersona : this.customerMarking,
        }).then(result =>{
            if (!result){
                console.log('result ->' + this.result);
            }else{
                //let data = JSON.parse(result);
                let data = result;
                let slots = [];
                try{
                    slots = data.data;
                    this.data = [];
                    if(slots.length == 0){
                        const navigateNextElement = new FlowNavigationNextEvent();
                        this.dispatchEvent(navigateNextElement);
                    }
                    else{
                        slots.forEach(element => {
                            this.addRecord({
                                NrAtto : element.numeroProvvedimento,
                                DataAtto : element.dataProvvedimento,
                                TipoTributo : element.tipoTributo,
                                AccertamentoPer : element.tipoAccertamento,
                                Stato : element.stato,
                                BaseDati : element.bs,
                                DataInizio : element.DataInizio,//OP
                                DataFine : element.DataFine,//OP
                                Soggetto : element.ragioneSociale,
                                Indirizzo : element.via,
                                Civico : element.civico,
                                Contratto : element.pratica,
                                SuperficieAccertata : element.SuperficieAccertata,//OP
                                CategoriaAccertata : element.CategoriaAccertata//OP
                            });
                        });
                        this.data.sort(this.sortBy('NrAtto', -1));
                    }
                }catch(e){
                    console.error(e);
                    this.showAlert('Attenzione','Errore nella chiamata al server. Non è stato ricevuto un appuntamento valido.','error');
                }
            } 
        }).catch(error =>{
            this.showAlert('Attenzione',error.body.message,'error');
        });
    }

    addRecord(element){
        this.data = [...this.data,element];
    }

    showAlert(_title,_message,_variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title: _title,
                message: _message,
                variant: _variant
            })
        );
    }
            
}