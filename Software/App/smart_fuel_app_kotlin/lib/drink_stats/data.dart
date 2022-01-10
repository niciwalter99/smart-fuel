import 'package:simple_cluster/src/dbscan.dart';


// Class for Storing values
class WaterLevel {
  final int timestamp;
  final int value;
  final int cluster;

  WaterLevel(this.timestamp, this.value, this.cluster);
}

class DayStats {
    final int sumOfWater;
    final int bottleFillUp;
    final int nipCounter;
    final int avgGulpSize;

    DayStats({required this.sumOfWater, required this.bottleFillUp, required this.nipCounter, required this.avgGulpSize});
}

class Cluster {

}

class Data {
  List<List<int>> inputData = [];
  List<int> clusters = [];
  List<WaterLevel> waterLevelPoints = [];
  List<List<int>> clusteredAverages = [];

  void calculateCluster(int minSamples, int epsilon, List<int> inputData) {
      List<int> labels = [];
      int _minSamples = minSamples - 1;

      //Values for Calculation
      int clusterValue = 0;
      int yValueAvg = 0;
      int yValueSum = 0;
      int numSamples = 1;
      int lastValue = 0;

      for(int point in inputData) {

        if ((point - lastValue).abs() > 10) {
          lastValue = point;
          labels.add(-1);
          continue;
        }
        else if (point == 0) {
          labels.add(-1);
          continue;
        }
        else {
          lastValue = point;
        }

        if ((point - yValueAvg).abs() < epsilon) {
          if (numSamples < _minSamples) {
            numSamples += 1;
            labels.add(-1); // clustered as noise
          }

          else if(numSamples == _minSamples) {
            numSamples += 1;
            clusterValue += 1;
            labels.add(clusterValue);
            for (int i = 0; i < _minSamples; i++) {
              labels[labels.length - 1 - i] =
                  clusterValue; // Define all Values as non Noise with cluster Value
            }
          }
          else {
            labels.add(clusterValue);
            numSamples += 1;
          }
        }
        else {
          labels.add(-1);
          numSamples = 1;
          yValueSum = 0;
        }

        yValueSum += point;
        yValueAvg = (yValueSum ~/ numSamples).toInt();

      }
      clusters = labels;

      // Prepare input Data -> Give each point a Timestamp
      this.inputData = [];
      for (int i = 0; i < inputData.length; i++) {
        this.inputData.add([i, inputData[i]]);
      }
    }

  void filterData(){

    for (int i = 0; i < inputData.length; i++) {
      if (clusters[i] != -1) {
        waterLevelPoints.add(WaterLevel(
            inputData[i][0].toInt(), inputData[i][1].toInt(),
            clusters[i]));
      }
    }

    int sumOfClusterValues = 0;
    int countOfClusterValues = 0;
    int cluster = 0;
    int timestampOfFirstClusterPoint = 0;

    for (WaterLevel point in waterLevelPoints) {
      if (point.cluster == cluster) {
        if (sumOfClusterValues == 0) {
          timestampOfFirstClusterPoint = point.timestamp;
        }

        sumOfClusterValues += point.value;
        countOfClusterValues++;
      }

      if (point.cluster == cluster + 1 ||
          point.timestamp == waterLevelPoints.last.timestamp) {

        // Prevent divide by 0 Exception
        if(countOfClusterValues > 0 ) {
          clusteredAverages.add([
            sumOfClusterValues ~/ countOfClusterValues,
            timestampOfFirstClusterPoint
          ]);
        }
        sumOfClusterValues = 0;
        countOfClusterValues = 0;
        cluster += 1;
      }
    }

    // Additional Filter for Values smaller than Tara Value (Value of the Bottle, here 160gram).
    clusteredAverages.removeWhere((element) => element[0] <= 10);

    print("Result of Data Preparation");
    print(clusteredAverages);

  }

  DayStats analyzeData(){
    if(clusteredAverages.isEmpty) {
      return DayStats(sumOfWater: 0,
          bottleFillUp:0,
          nipCounter:0,
          avgGulpSize:0);
    }
    List<List<int>> averagedClusterValues = clusteredAverages;
    int waterDrunk = 0;
    List<List<int>> refillPoints = [];
    int gulpCounter = 0;

    for (int i = 0; i < averagedClusterValues.length - 1; i++) {
      int curPoint = averagedClusterValues[i][0];
      int nextPoint = averagedClusterValues[i + 1][0];

      if ((curPoint - nextPoint) < 0) {
        refillPoints.add(
            [averagedClusterValues[i + 1][1], averagedClusterValues[i + 1][0]]);
      }
      else {
        waterDrunk += curPoint - nextPoint;
        gulpCounter += 1;
      }
    }

    int avgGulpSize = 0;
    if(gulpCounter != 0) {
      avgGulpSize =waterDrunk * 10 ~/ gulpCounter;
    }

    return DayStats(sumOfWater: waterDrunk*10.toInt(),
        bottleFillUp:refillPoints.length,
        nipCounter:gulpCounter,
        avgGulpSize:avgGulpSize);
    // print("You Drank ${waterDrunk*10.toInt()} ml of water!");
    // print("Your filled up your Bottle ${refillPoints.length} time(s)");
    // print("You nipped $gulpCounter times on your Bottle");
    // print("Your average Gulp Size is ${waterDrunk * 10 / gulpCounter} ml");
  }

  List<List<int>> getDataForPlot() {
    if(clusteredAverages.isEmpty) {
      return [];
    }
    List<List<int>> filteredData = clusteredAverages;
    List<List<int>> dataForPlot = [];

    for(int i = 0; i < filteredData.length; i++) {
      if((i + 1 )< filteredData.length) {
        dataForPlot.add(filteredData[i]);
        dataForPlot.add([filteredData[i][0], filteredData[i+1][1] - 1]);
      } else {
        dataForPlot.add(filteredData[i]);
        dataForPlot.add([filteredData[i][0], filteredData[i][1] + 400]);
      }
    }

    return dataForPlot;
  }
}