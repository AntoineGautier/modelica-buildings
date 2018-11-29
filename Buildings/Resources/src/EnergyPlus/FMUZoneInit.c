/*
 * Modelica external function to communicate with EnergyPlus.
 *
 * Michael Wetter, LBNL                  2/14/2018
 */

#include "FMUEnergyPlusStructure.h"
#include "ModelicaUtilities.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>


int zoneIsUnique(const struct FMUBuilding* fmuBld, const char* zoneName){
  int iZ;
  int isUnique = 1;
  for(iZ = 0; iZ < fmuBld->nZon; iZ++){
    if (!strcmp(zoneName, fmuBld->zoneNames[iZ])){
      isUnique = 0;
      break;
    }
  }
  return isUnique;
}

/* Create the structure and return a pointer to its address. */
void* FMUZoneInit(const char* idfName, const char* weaName, const char* iddName, const char* epLibName, const char* zoneName)
{
  writeLog(1, "Initializing zone.");
  /* Note: The idfName is needed to unpack the fmu so that the valueReference
     for the zone with zoneName can be obtained */
  unsigned int i;
  size_t len;
  const size_t nFMU = getBuildings_nFMU();
  /* ModelicaMessage("*** Entered FMUZoneInit."); */

  /* ModelicaFormatMessage("****** Initializing zone %s, fmu = %s****** \n", zoneName, idfName); */

  /* ********************************************************************** */
  /* Initialize the zone */
  FMUZone* zone = (FMUZone*) malloc(sizeof(FMUZone));
  if ( zone == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone.");

  /* Assign the zone name */
  zone->name = malloc((strlen(zoneName)+1) * sizeof(char));
  if ( zone->name == NULL )
    ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone name.");
  strcpy(zone->name, zoneName);
  /* Set the number of inputs and outputs to zero. This will be used to check if
     the data structures for the inputs and outputs
     have already been set in a call in the 'initial equation' section
  */
  zone->nInputValueReferences = 1;
  zone->nOutputValueReferences = 4;

  char** fullInpNames = NULL;
  char** fullOutNames = NULL;

  const char* consInputNames[]={"T"};
  const char* consOutputNames[]={"QConSen_flow", "V", "AFlo", "mSenFac"};

  /* Set the input and output names. The value references will be set when all zones are assembled */
  /* buildVariableNames calls malloc on fullInpNames */
  buildVariableNames(zone->name, consInputNames, zone->nInputValueReferences, &fullInpNames, &len);
  /* Copy the string arrays */

  zone->inputVariableNames = (char**)malloc(zone->nInputValueReferences * sizeof(char*));
  if ( zone->inputVariableNames == NULL)
    ModelicaFormatError("Failed to allocate memory for inputVariableNames.");

  for(i = 0; i < zone->nInputValueReferences; i++){
    zone->inputVariableNames[i] = (char*)malloc(len * sizeof(char));
    if ( zone->inputVariableNames[i] == NULL)
      ModelicaFormatError("Failed to allocate memory for inputVariableNames[i].");
  }

  for(i = 0; i < zone->nInputValueReferences; i++){
    memcpy(zone->inputVariableNames[i], fullInpNames[i], len);
  }

  for(i = 0; i < zone->nInputValueReferences; i++)
    free(fullInpNames[i]);
  free(fullInpNames);

  zone->inputValueReferences = NULL;

  buildVariableNames(zone->name, consOutputNames, zone->nOutputValueReferences, &fullOutNames, &len);
  zone->outputVariableNames = fullOutNames;
  zone->outputValueReferences = NULL;

  /* ********************************************************************** */
  /* Initialize the pointer for the FMU to which this zone belongs */
  /* Check if there are any zones */
  if (nFMU == 0){
    /* No FMUs exist. Instantiate an FMU and */
    /* assign this fmu pointer to the zone that will invoke its setXXX and getXXX */
    zone->ptrBui = FMUZoneAllocateBuildingDataStructure(idfName, weaName, iddName, epLibName, zoneName, zone);
    zone->index = 1;
  } else {
    /* There is already a Buildings FMU allocated.
       Check if the current zone is for this FMU. */
      zone->ptrBui = NULL;
      for(i = 0; i < nFMU; i++){
        FMUBuilding* fmu = getBuildingsFMU(i);
        if (strcmp(idfName, fmu->name) == 0){
          /* This is the same FMU as before. */
          if (! zoneIsUnique(fmu, zoneName)){
            ModelicaFormatError("Modelica model specifies zone %s twice for the FMU %s. Each zone must only be specified once.",
            zoneName, fmu->name);
          }

          zone->ptrBui = fmu;
          /* Increment size of vector that contains the zone names. */
          fmu->zoneNames = realloc(fmu->zoneNames, (fmu->nZon + 1) * sizeof(char*));
          fmu->zones = realloc(fmu->zones, (fmu->nZon + 1) * sizeof(FMUZone*));
          if (fmu->zoneNames == NULL){
            ModelicaError("Not enough memory in FMUZoneInit.c. to allocate memory for bld->zoneNames.");
          }
          /* Add storage for new zone name, and copy the zone name */
          fmu->zoneNames[fmu->nZon] = malloc((strlen(zoneName)+1) * sizeof(char));
          if ( fmu->zoneNames[fmu->nZon] == NULL )
            ModelicaError("Not enough memory in FMUZoneInit.c. to allocate zone name.");
          fmu->zones[fmu->nZon] = zone;
          strcpy(fmu->zoneNames[fmu->nZon], zoneName);
          /* Increment the count of zones to this building. */
          fmu->nZon++;
          zone->index = fmu->nZon;
          break;
        }
      }
      /* Check if we found an FMU */
      if (zone->ptrBui == NULL){
        /* Did not find an FMU. */
        zone->ptrBui = FMUZoneAllocateBuildingDataStructure(idfName, weaName, iddName, epLibName, zoneName, zone);
      }
  }
  /*Set the fmu to null to control execution*/
  zone->ptrBui->fmu=NULL;

  /* Return a pointer to this zone */
  return (void*) zone;
};
