@Core.LongDescription        : 'Supplier Footprint Service'
@Core.SchemaVersion          : '2.0.0'
@Authorization.Authorizations: [{
    $Type      : 'Authorization.OAuth2ClientCredentials',
    Name       : 'oauth_clientcredentials',
    Description: 'Authentication via OAuth2 with client credentials flow.',
    Scopes     : [{
        Scope      : 'c21-business-data-publisher',
        Description: 'The role required for working with this API.'
    }],
    TokenUrl   : 'https://example.authentication.eu20.hana.ondemand.com/oauth/token'
}]
@rest
@Capabilities.BatchSupported : false
service SupplierFootprintService @(path: '/supplier-footprint-service') {
    define type EnvironmentalImpacts {
        category       : String(10) not null      @mandatory  @assert.range  enum {
            CLCH;
            CLCF;
            CCFL;
            CLCB;
            CLCN;
            CLCLU;
            CLCLM;
            RELM;
            RECCS;
            REDCC;
            REPCC;
            ADPF;
            ADPM;
        };
        value          : Decimal(31, 14) not null @mandatory;
        lifecycleStage : String(20)               @assert.range enum {
            Transport
        };
    }

    define type EnvironmentalProperties {
        type  : String(50) not null      @mandatory;
        value : Decimal(31, 14) not null @mandatory;
        unit  : String(3)                @assert.range enum {
            kgC;
            kg;
        };
    }


    define type CrossSectoralStandard       : String @assert.range enum {
        ISO14067;
        ISO14083;
        ISOI4040_44 = 'ISO14040-44';
        GHGProduct = 'GHG-Product';
    };

    define type IpccCharacterizationFactor  : String @assert.format: '^AR[0-9]+$';

    define type EmissionFactorSource {
        name    : String;
        version : String;
    }

    define type ProductOrSectorSpecificRule {
        operator          : String @assert.range enum {
            PEF;
            EPD_INTERNATIONAL = 'EPD International';
            Other;
        };
        ruleNames         : many String;
        otherOperatorName : String;
    }

    define type IpccCharacterizationFactors : String @assert.format: '^AR[0-9]+$';

    define type AdditionalData {
        boundaryProcessesDescription   : String;
        ipccCharacterizationFactors    : many IpccCharacterizationFactors;
        crossSectoralStandards         : many CrossSectoralStandard;
        productOrSectorSpecificRules   : many ProductOrSectorSpecificRule;
        exemptedEmissionsPercent       : Decimal(31, 14);
        exemptedEmissionsDescription   : String;
        allocationRulesDescription     : String;
        secondaryEmissionFactorSources : many EmissionFactorSource;
        dqi                            : DataQualityIndicators;
        verification                   : Verification;
    }

    define type DataQualityIndicators {
        technologicalDQR : Decimal(31, 14);
        geographicalDQR  : Decimal(31, 14);
        temporalDQR      : Decimal(31, 14);
    }

    define type Verification {
        coverage     : String @assert.range enum {
            PCF_Calculation_Model = 'PCF calculation model';
            PCF_Program = 'PCF program';
            Product_Level = 'product level';
        };
        providerName : String;
        completedAt  : DateTime;
        standardName : String;
        comments     : String;
    }

    type CarbonFootprint {
        @Core.LongDescription: 'The unit of measurement of the product. Together with declaredUnitAmount this defines the "declared unit" of the product. Emissions in this carbon footprint are expressed in kgCO2e per "declared unit".'
        declaredUnitOfMeasurement  : String(10) not null      @mandatory;

        @Core.LongDescription: 'The amount of units contained within the product to which the PCF is referring.'
        declaredUnitAmount         : Decimal(31, 14) not null @mandatory;

        @Core.LongDescription: 'The start (inclusive) of the time boundary for which the PCF value is considered to be representative. Specifically, this start date represents the earliest date from which activity data was collected to include in the PCF calculation.'
        referencePeriodStart       : DateTime not null        @mandatory;

        @Core.LongDescrption : 'The end (exclusive) of the time boundary for which the PCF value is considered to be representative. Specifically, this end date represents the latest date from which activity data was collected to include in the PCF calculation.'
        referencePeriodEnd         : DateTime not null        @mandatory;

        @Core.LongDescription: 'If present, the value MUST be one of the UN geographic regions or UN geographic subregions.'
        geographyRegionOrSubregion : String(50)               @assert.range enum {
            Africa;
            Americas;
            Asia;
            Europe;
            Oceania;
            Australia_NewZealand = 'Australia and New Zealand';
            Central_Asia = 'Central Asia';
            Eastern_Asia = 'Eastern Asia';
            Eastern_Europe = 'Eastern Europe';
            Latin_America_Caribbean = 'Latin America and the Caribbean';
            Melanesia;
            Micronesia;
            Northern_Africa = 'Northern Africa';
            Northern_America = 'Northern America';
            Northern_Europe = 'Northern Europe';
            Polynesia;
            South_Eastern_Asia = 'South-eastern Asia';
            Southern_Asia = 'Southern Asia';
            Southern_Europe = 'Southern Europe';
            Sub_Saharan_Africa = 'Sub-Saharan Africa';
            Western_Asia = 'Western Asia';
            Western_Europe = 'Western Europe';

        };

        @Core.LongDescription: 'If present, the value MUST conform to the ISO 3166-1 alpha-2 country code'
        geographyCountry           : String(2)                @assert.format: '^[A-Z]{2}$';

        @Core.LongDescription: 'If present, a ISO 3166-2 country and subdivision code.'
        geographyRegion            : String(3)                @assert.format: '^[A-Z0-9]{1,3}$';

        @Core.LongDescription: 'Share of primary data in the final absolute PCF value excluding biogenic CO2 uptake.'
        primaryDataShare           : Decimal(31, 14);

        @Core.LongDescription: 'Environmental impacts'
        environmentalImpacts       : many EnvironmentalImpacts not null;

        @Core.LongDescription: 'Environmental properties'
        environmentalProperties    : many EnvironmentalProperties;
    }

    type Extension {
        name  : String not null @mandatory;
        value : String not null @mandatory;
    }

    @Core.LongDescription: 'Supplier Footprint Data Input Structure'
    define type SupplierFootprintInput {
            @Core.LongDescription: 'A unique identifier that a system uses to refer to the entire dataset of the PCF. This is typically an automatically-generated number by the solution to maintain the required technical references to data within the system.'
        id                  : UUID not null            @mandatory  @assert.format: '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$';

            @Core.LongDescription: 'Name of the Standard.'
        standardName        : String not null          @mandatory  @assert.range  enum {

            @Core.LongDescription: 'PACT PCF Data Exchange'
        PACT;

            @Core.LongDescription: 'TfS Product Carbon Footprint'
        TFS = 'TfS';

            @Core.LongDescription: 'Catena-X Automotive Network'
        CATENA_X = 'Catena-X';

            @Core.LongDescription: 'Forest, Land and Agriculture (FLAG) - Science Based Targets'
        SBTI_FLAG = 'SBTi FLAG';

            @Core.LongDescription: 'Product Environmental Footprint Category Rules'
        PEFCR; // 'Product Environmental Footprint Category Rules';

            @Core.LongDescription: 'GHG Land Sector and Removals Standard'
        GHG_LSRS = 'GHG-LSRS'; // 'GHG Land Sector and Removals Standard';
        };

            @Core.LongDescription: 'Version of the Standard.'
        standardVersion     : String(10);

            @Core.LongDescription: 'A given PCF may change over time, due to updates to the calculation. This is a list of IDs that reflect "past versions" of the current PCF, maintained by the solution. If defined, MUST be non-empty set of IDs.'
        precedingPfIds      : many UUID;

            // version             : Integer         @assert.min: 0;
        @Core.LongDescription    : 'The date and time when the PCF was created. This is typically an automatically generated field by the solution. It SHOULD NOT be used to derive status of validity of the PCF.'
        created             : DateTime not null        @mandatory;

            @Core.LongDescription: 'The status of the PCF. Active means that the PCF is the most recent version and is the one that SHOULD be used by a data recipient, e.g. for product footprint calculations. Deprecated means that the PCF is no longer the most recent version and SHOULD NOT be used by data recipients.'
        status              : String(10) not null      @mandatory  @assert.range  enum {
            Active;
            Deprecated
        };

            @Core.LongDescription: 'The start date of the validity period: the time interval during which the ProductFootprint is declared as valid for use by a receiving data recipient. If no validity period is specified, the ProductFootprint is valid for 3 years after the referencePeriodEnd'
        validityPeriodStart : DateTime;

            @Core.LongDescription: 'The end date and time of the validity period. After this date the ProductFootprint is not valid for use anymore.'
        validityPeriodEnd   : DateTime;
        supplierId          : String(50) not null      @mandatory;
        productId           : String(50) not null      @mandatory;
        comment             : String;

            @Core.LongDescription: 'The carbon footprint of the given product.'
        pcf                 : CarbonFootprint not null @mandatory;

            @Core.LongDescription: 'Additional data related to the PCF.'
        additionalData      : AdditionalData;

            @Core.LongDescription: 'A list of extended attribute to the standard PCF structure.'
        extensions          : many Extension;
    }


    define type SupplierFootprintOutput {
        id     : UUID;
        status : String(20);
    }


    @Core.Description: 'Post Supplier Footprint Data via agnostic interface'
    action push(data: many SupplierFootprintInput) returns many SupplierFootprintOutput;
}
