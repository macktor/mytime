//
//  k-mean.swift
//  myTime
//
//  Created by Marcus on 4/12/16.
//  Copyright © 2016 Marcus. All rights reserved.
//

import Foundation
import Darwin
class KMean {
    var clusters: [[Double]]!
    var testData: [[Double]] = [
        [37.71839311, -122.44839194,805],
        [37.72203446, -122.4479617,856],
        [37.72913917, -122.44170193,856],
        [37.73219291, -122.43066732,857],
        [37.73190692, -122.4191826,857],
        [37.73467442, -122.40896246,858],
        [37.74154292, -122.40736102,858],
        [37.74815646, -122.40393139,859],
        [37.75593629, -122.40310762,859],
        [37.76191539, -122.40588589,860],
        [37.386369, -122.15330226,867],
        [37.38966543, -122.16308369,867],
        [37.39275592, -122.17367289,868],
        [37.39946853, -122.181674,868],
        [37.40684142, -122.18921084,869],
        [37.41070502, -122.19932176,869],
        [37.41487543, -122.2096481,870],
        [37.41911693, -122.21945669,870],
        [37.42467819, -122.22918858,871],
        [37.43097283, -122.23774147,871],
        [37.43767153, -122.24587351,872],
        [37.44364246, -122.25458952,872],
        [37.44383755, -122.26580291,873],
        [37.44826202, -122.275525,873],
        [37.45448608, -122.28487643,874],
        [37.46211156, -122.29069557,874],
        [37.47074882, -122.29417431,975],
        [37.47867584, -122.29926607,975],
        [37.48769154, -122.29820324,976],
        [37.49465019, -122.30499317,977],
        [37.49809315, -122.31513904,977],
        [37.5009279, -122.32568004,978],
        [37.50532023, -122.33564227,978],
        [37.5111431, -122.344613,979],
        [37.51775533, -122.35216409,979],
        [37.52578192, -122.35804173,980],
        [37.53449935, -122.36228381,980],
        [37.54248605, -122.36713492,981],
        [37.54963058, -122.37438493,981],
        [37.55765507, -122.38068687,982],
        [37.56522335, -122.38807141,982],
        [37.57070804, -122.39676126,983],
        [37.57874084, -122.40206793,983],
        [37.58607534, -122.40858662,984],
        [37.5933155, -122.41641054,984],
        [37.60033635, -122.42425684,985],
        [37.60842489, -122.42770088,985],
        [37.6171207, -122.42417176,986],
        [37.62552984, -122.42915698,986],
        [37.63243678, -122.43724443,987],
        [37.64069467, -122.44278177,987],
        [37.64724442, -122.45059714,988],
        [37.6543464, -122.45663554,988],
        [37.66101878, -122.46472945,989],
        [37.67030362, -122.46611581,989],
        [37.67831194, -122.47149867,990],
        [37.68708935, -122.47110087,990],
        [37.69605048, -122.47064958,991],
        [37.7045799, -122.47122492,991],
        [37.71043642, -122.46355472,992],
        [37.71224348, -122.45340591,992],
        [37.71990228, -122.44822204,993],
        [37.72822722, -122.44357117,993],
        [37.7319342, -122.43285642,994],
        [37.73163539, -122.42178024,994],
        [37.73375236, -122.4109307,995],
        [37.73987094, -122.4078351,995],
        [37.74639684, -122.40450698,996],
        [37.75430156, -122.40294124,1096]]
    
    
    func distance(a: [Double], b: [Double]) -> (Double) {
        return sqrt(pow(a[0]-b[0], 2) + pow(a[1]-b[1], 2))
    }

    func assignLabels(data: [[Double]], clusters: [[Double]]) -> ([Int]) {
        // Initialize labels
        var labels = [Int](count: data.count, repeatedValue: 0)
        
        // Find the cluster closest to this data and assign it
        // as the new label
        for i in 0 ..< data.count {
            var minDistance = Double(Int64.max)
            for j in 0 ..< clusters.count {
                let dist = distance(data[i], b: clusters[j])
                if dist < minDistance {
                    minDistance = dist
                    labels[i] = j
                }
            }
        }
        
        return labels
    }


    func kMeans(data: [[Double]], clusters: [[Double]], minChange: Double) -> ([[Double]], [Int]) {
        var prevClusters = clusters
        var newClusters = [[Double]](count: prevClusters.count, repeatedValue: [0.0, 0.0])
        var changed = true
        var labels: [Int]?
        
        // Run algorithm until cluster locations don't change
        while changed {
            labels = assignLabels(data, clusters: prevClusters)
            
            // Compute new cluster positions
            for i in 0 ..< prevClusters.count {
                var mean = [0.0, 0.0]
                var count = 0
                for j in 0 ..< data.count {
                    if labels![j] == i {
                        mean[0] += data[j][0]
                        mean[1] += data[j][1]
                        count += 1
                    }
                }
                newClusters[i][0] = mean[0] / Double(count)
                newClusters[i][1] = mean[1] / Double(count)
            }
            changed = false
            
            // Check if any of the cluster changes exceed the threshold
            for i in 0 ..< prevClusters.count {
                if distance(prevClusters[i], b: newClusters[i]) >= minChange {
                    changed = true
                    break
                }
            }
            
            prevClusters = newClusters
        }
        
        return (newClusters, labels!)
    }
    func calculateClusters(timestamps: [Double], data: [[Double]]) -> ([[Double]]){
        let clusterBreakpoint: Double = 30
        var clusterIndices: [Int] = []
        var initialClusters: [[Double]] = []
        
        for i in 1 ..< timestamps.count {
            let timeDiff: Double = timestamps[i] - timestamps[i-1]
            if timeDiff > clusterBreakpoint{
                clusterIndices.append(i)
            }
        }
        for i in 0 ..< clusterIndices.count {
            initialClusters.append(data[clusterIndices[i]])
        }
        return initialClusters
        
    }
    func doTheWork( var data: [[Double]], var timestamps: [Double] ){
        // Data in (x,y) format
        data.removeAll()
        timestamps.removeAll()
        for d in testData {
            data.append([d[0],d[1]])
            timestamps.append(d[2])
        }

        // Initial cluster locations in (x,y) format
        //let initialClusters: [[Double]] = [data[0], data[data.count-1]]
        print("datalength: " + String(data.count))
        
        let initialClusters: [[Double]] = calculateClusters(timestamps, data: data)
        
        print(String(initialClusters.count) + " initialclusters found")
        for i in 0 ..< initialClusters.count {
            print("Cluster[\(i)] at \(initialClusters[i])")
        }
        print()
        //Should be calculated by time spent in one location, set a minimum amount of time in one location and then calculate the clusters based on that.
        
        let (finalClusters, _) = kMeans(data, clusters: initialClusters, minChange: 0.0001)
        clusters = finalClusters
        
        // Print out new cluster positions
        print(String(clusters.count) + " finalclusters found")
        for i in 0 ..< clusters.count {
            print("Cluster[\(i)] at \(clusters[i])")
        }
    }
}