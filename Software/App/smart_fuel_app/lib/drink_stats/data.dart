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

class Data {
  List<List<double>> inputData = [];
  List<WaterLevel> waterLevelPoints = [];

  Data(List<int> rawInputData) {
    for (int i = 0; i < rawInputData.length; i++) {
      inputData.add([i.toDouble(), rawInputData[i].toDouble()]);
    }
  }

  Future<List<List<int>>> filterData() async{

    DBSCAN dbscan = DBSCAN(
      epsilon: 2,
      minPoints: 3,
    );
    dbscan.run(inputData);

    for (int i = 0; i < inputData.length; i++) {
      if (dbscan.label![i] != -1) {
        waterLevelPoints.add(WaterLevel(
            inputData[i][0].toInt(), inputData[i][1].toInt(),
            dbscan.label![i]));
      }
    }

    int sumOfClusterValues = 0;
    int countOfClusterValues = 0;
    int cluster = 0;
    int timestampOfFirstClusterPoint = 0;

    List<List<int>> averagedClusterValues = [];

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
        averagedClusterValues.add([
          sumOfClusterValues ~/ countOfClusterValues,
          timestampOfFirstClusterPoint
        ]);
        sumOfClusterValues = 0;
        countOfClusterValues = 0;
        cluster += 1;
      }
    }

    // Additional Filter for Values smaller than Tara Value (Value of the Bottle, here 160gram).
    averagedClusterValues.removeWhere((element) => element[0] <= 10);

    print("Result of Data Preparation");
    print(averagedClusterValues);
    return averagedClusterValues;
  }

  Future<DayStats> analyzeData(List<List<int>> averagedClusterValues) async{
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

  List<List<int>> getDataForPlot(List<List<int>> filteredData) {
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