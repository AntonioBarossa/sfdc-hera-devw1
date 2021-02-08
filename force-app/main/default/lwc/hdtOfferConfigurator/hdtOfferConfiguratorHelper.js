//file con 2000 record con tutti i campi formulati = 1.6MB
var dataRows = [
    {
        id: '1',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '2',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '3',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EP_PERS_MO'
    },    
    {
        id: '4',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '5',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: false},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '6',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'EP_PERS_MO'
    },
    {
        id: '7',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '8',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '9',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: false},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'EP_PERS_MO'
    },
    {
        id: '10',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: false},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '11',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: false},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: true},
        stringValue: {id: '', label: '', enabled: false},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '12',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EP_PERS_MO'
    },
    {
        id: '13',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '14',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '15',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EP_PERS_MO'
    },
    {
        id: '16',
        definition: 'EE Valore PRZ indice data att',
        checkUser: false,
        amount: {id: '', label: '', enabled: false},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: true},
        discount: {id: '', label: '', enabled: false},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EFP_CT_MI'
    },
    {
        id: '17',
        definition: 'EE Percentuale Adeg. Indice',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'ES_ADG_CT'
    },
    {
        id: '18',
        definition: 'EE Prezzo personalizzato Mono',
        checkUser: false,
        amount: {id: '', label: '', enabled: true},
        grInfo: {id: '', label: '', enabled: true},
        price: {id: '', label: '', enabled: false},
        discount: {id: '', label: '', enabled: true},
        value: {id: '', label: '', enabled: false},
        stringValue: {id: '', label: '', enabled: true},
        tecName: 'EP_PERS_MO'
    }
];

export default function appDataHelper() {
    return dataRows;
}