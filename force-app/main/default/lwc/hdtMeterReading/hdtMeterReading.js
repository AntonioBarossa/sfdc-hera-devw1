import { LightningElement, api, track } from 'lwc';

const contractColumns = [
    {
        label: '',
        type: 'button',
        initialWidth: 110,
        typeAttributes: {
                            label: 'Visualizza',
                            title: 'Seleziona',
                            variant: 'border-filled',
                            alternativeText: 'Seleziona'
                        }
    },
    {label: 'Numero Contratto', fieldName: 'contractNumber'},
    {label: 'Stato', fieldName: 'status'},
    {label: 'Data inizio', fieldName: 'startDate'},
    {label: 'Data fine', fieldName: 'endDate'},
    {label: 'Fornitura', fieldName: 'asset'},
    {label: 'Servizio', fieldName: 'service'}
];

const contractData = [
    {
        Id: '1',
        contractNumber: '2001',
        status: 'Draft',
        startDate: '03/05/2018',
        endDate: '01/06/2020',
        asset: 'SP-0001',
        service: 'ELE'
    },
    {
        Id: '2',
        contractNumber: '2002',
        status: 'Draft',
        startDate: '02/02/2018',
        endDate: '02/05/2020',
        asset: 'SP-0001',
        service: 'GAS'
    }
];

const dataToView = [];

export default class HdtMeterReading extends LightningElement {
    @api recordid;
    @track selid;
    @track selectRecordName;
    @track bShowModal = true;
    @track data = [];
    @track contractColumns = contractColumns;
    @track detailTableHeader = 'Letture';

    async connectedCallback() {
        this.data = contractData;
    }

    @track lettureData;
    @track columns = columns;

    changeContractId(c){
        console.log('#### ' + c);
        var dataToView = [];
        var i;
        for(i=0; i<accountData.length; i++){
            if(accountData[i].contractId == c){
                dataToView.push(accountData[i]);
            }
        }
        this.lettureData = dataToView;
    }

    handleRowAction(event) {
        console.log('# handleRowAction #');
        /*console.log('# -> ' + event.detail.currentRecId);
        console.log('# -> ' + event.detail.selectName);
        this.selid = event.detail.currentRecId;
        this.selectRecordName = event.detail.selectName;*/
        //this.bShowModal = true;
        this.detailTableHeader = 'Letture ' + event.detail.row.contractNumber;
        this.changeContractId(event.detail.row.Id);
        //this.template.querySelector('c-view-data-table').changeContractId(event.detail.row.Id);
    }
}
    const columns = [
        { label: 'Data lettura', fieldName: 'lectureDate', initialWidth: 150},
        { label: 'Fascia', fieldName: 'slot', initialWidth: 150},
        { label: 'Lettura (Interi)', fieldName: 'lectureInt', initialWidth: 150},
        { label: 'Lettura (Decimal)', fieldName: 'lectureDecimal', initialWidth: 150},
        { label: 'Consumo', fieldName: 'consumed', initialWidth: 150},
        { label: 'Codice Apparecchio', fieldName: 'assetCode', initialWidth: 150},
        { label: 'Codice Contratto', fieldName: 'contractCode', initialWidth: 150},
        { label: 'Stato', fieldName: 'status', initialWidth: 150},
        { label: 'Tipo lettura', fieldName: 'lectureType', initialWidth: 150},
        { label: 'Causale', fieldName: 'reason', initialWidth: 150},
        { label: 'Giorni di fatturazione', fieldName: 'billingDate', initialWidth: 150},
        { label: 'Consumo medio', fieldName: 'consumedAvg', initialWidth: 150},
        { label: 'Tipo registro', fieldName: 'regType', initialWidth: 150},
        { label: 'Consumo', fieldName: 'consumed', initialWidth: 150},
        { label: 'Unità di misura', fieldName: 'meters', initialWidth: 150},
        { label: 'Tipo di consumo', fieldName: 'consumedType', initialWidth: 150},
        { label: 'Settore merceologico', fieldName: 'sector', initialWidth: 150},
        { label: 'Flag lettura', fieldName: 'consumed', initialWidth: 150},
        { label: 'Motivazione', fieldName: 'reasonWhy', initialWidth: 150}
    ];
    
    const accountData = [
        {id: '1', contractId: '1', lectureDate: '28/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0001', consumed: '1.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '2', contractId: '1', lectureDate: '29/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0002', consumed: '2.00', assetCode: 'R0010005', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '3', contractId: '1', lectureDate: '30/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0003', consumed: '3.00', assetCode: 'R0010006', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '4', contractId: '2', lectureDate: '12/01/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0004', consumed: '4.00', assetCode: 'R0010007', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '5', contractId: '2', lectureDate: '23/02/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0005', consumed: '5.00', assetCode: 'R0010008', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '6', contractId: '2', lectureDate: '24/03/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0006', consumed: '6.00', assetCode: 'R0010009', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '7', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0007', consumed: '7.00', assetCode: 'R0010010', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '8', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0008', consumed: '8.00', assetCode: 'R0010011', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '9', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0009', consumed: '9.00', assetCode: 'R0010012', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '10', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0010', consumed: '10.00', assetCode: 'R0010013', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '11', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0011', consumed: '11.00', assetCode: 'R0010014', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '12', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0012', consumed: '12.00', assetCode: 'R0010015', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '13', contractId: '5', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0013', consumed: '13.00', assetCode: 'R0010016', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '14', contractId: '1', lectureDate: '28/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0001', consumed: '1.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '15', contractId: '1', lectureDate: '29/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0002', consumed: '2.00', assetCode: 'R0010005', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '16', contractId: '1', lectureDate: '30/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0003', consumed: '3.00', assetCode: 'R0010006', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '17', contractId: '2', lectureDate: '12/01/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0004', consumed: '4.00', assetCode: 'R0010007', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '18', contractId: '2', lectureDate: '23/02/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0005', consumed: '5.00', assetCode: 'R0010008', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '19', contractId: '2', lectureDate: '24/03/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0006', consumed: '6.00', assetCode: 'R0010009', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '20', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0007', consumed: '7.00', assetCode: 'R0010010', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '21', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0008', consumed: '8.00', assetCode: 'R0010011', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '22', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0009', consumed: '9.00', assetCode: 'R0010012', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '23', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0010', consumed: '10.00', assetCode: 'R0010013', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '24', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0011', consumed: '11.00', assetCode: 'R0010014', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '25', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0012', consumed: '12.00', assetCode: 'R0010015', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '26', contractId: '5', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0013', consumed: '13.00', assetCode: 'R0010016', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '27', contractId: '1', lectureDate: '28/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0001', consumed: '1.00', assetCode: 'R0010004', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '28', contractId: '1', lectureDate: '29/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0002', consumed: '2.00', assetCode: 'R0010005', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '29', contractId: '1', lectureDate: '30/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0003', consumed: '3.00', assetCode: 'R0010006', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '30', contractId: '2', lectureDate: '12/01/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0004', consumed: '4.00', assetCode: 'R0010007', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '31', contractId: '2', lectureDate: '23/02/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0005', consumed: '5.00', assetCode: 'R0010008', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '32', contractId: '2', lectureDate: '24/03/2019', slot: 'Fascia 1', lectureInt: '123', lectureDecimal: '0.0006', consumed: '6.00', assetCode: 'R0010009', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '33', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0007', consumed: '7.00', assetCode: 'R0010010', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '34', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0008', consumed: '8.00', assetCode: 'R0010011', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '35', contractId: '3', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0009', consumed: '9.00', assetCode: 'R0010012', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '36', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0010', consumed: '10.00', assetCode: 'R0010013', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '37', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0011', consumed: '11.00', assetCode: 'R0010014', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '38', contractId: '4', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0012', consumed: '12.00', assetCode: 'R0010015', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
        {id: '39', contractId: '5', lectureDate: '31/03/2019', slot: 'Fascia 1', lectureInt: '575', lectureDecimal: '0.0013', consumed: '13.00', assetCode: 'R0010016', contractCode: '300145966', status: 'Calcolabile', lectureType: 'Stima automatica', reason: 'Stima automatica', billingDate: '0', consumedAvg: '0.000', regType: 'Energia attivaa', consumed: '', meters: 'KWH', consumedType: '', sector: 'Energia Elettrica', consumed: '', reasonWhy: ''},
    
    ];