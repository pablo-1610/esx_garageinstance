Config = {
    prefix = "[~o~Garages~s~] ~s~",

    garageType = {
        [1] = {
            label = "~g~2 Places",
            entry = { pos = vector3(178.69, -1006.31, -99.0), heading = 93.74 },
            max = 2,
            manager = vector3(177.39, -1000.21, -99.0),
            slots = {
                { pos = vector3(175.22, -1003.46, -99.0), heading = 183.32 },
                { pos = vector3(171.07, -1003.78, -99.), heading = 180.28 }
            }
        },


        [2] = {
            label = "~y~4 Places",
            entry = { pos = vector3(206.88, -1018.4, -99.0), heading = 89.34 },
            max = 4,
            manager = vector3(205.53, -1014.68, -99.0),
            slots = {
                { pos = vector3(194.50, -1016.14, -99.0), heading = 180.13 },
                { pos = vector3(194.57, -1022.32, -99.0), heading = 180.13 },
                { pos = vector3(202.21, -1020.14, -99.0), heading = 90.13 },
                { pos = vector3(202.21, -1023.32, -99.0), heading = 90.13 }
            }
        },

        [3] = {
            label = "~o~6 Places",
            entry = { pos = vector3(206.79, -999.08, -99.0), heading = 92.02 },
            max = 6,
            manager = vector3(205.65, -995.29, -99.0),
            slots = {
                { pos = vector3(203.82, -1004.63, -99.0), heading = 88.05 },
                { pos = vector3(194.16, -1004.63, -99.0), heading = 266.42 },
                { pos = vector3(193.83, -1000.63, -99.0), heading = 266.42 },
                { pos = vector3(202.62, -1000.63, -99.0), heading = 88.05 },
                { pos = vector3(193.83, -997.01, -99.0), heading = 266.42 },
                { pos = vector3(202.62, -997.01, -99.0), heading = 88.05 },
            }
        },


        [4] = {
            label = "~r~10 Places",
            entry = { pos = vector3(240.71, -1004.96, -99.0), heading = 90.57 },
            max = 10,
            manager = vector3(234.41, -976.79, -99.0),
            slots = {
                { pos = vector3(233.47, -982.57, -99.0), heading = 90.1 },
                { pos = vector3(233.47, -987.57, -99.0), heading = 90.1 },
                { pos = vector3(233.47, -992.57, -99.0), heading = 90.1 },
                { pos = vector3(233.47, -997.57, -99.0), heading = 90.1 },
                { pos = vector3(233.47, -1002.57, -99.0), heading = 90.1 },
                { pos = vector3(223.55, -982.57, -99.0), heading = 266.36 },
                { pos = vector3(223.55, -987.57, -99.0), heading = 266.36 },
                { pos = vector3(223.55, -992.57, -99.0), heading = 266.36 },
                { pos = vector3(223.55, -997.57, -99.0), heading = 266.36 },
                { pos = vector3(223.55, -1002.57, -99.0), heading = 266.36 },
            }
        }
    },

    availableGarages = {
        -- Il s'aggit d'exemples, à vous de les configurer comme bon vous semble
        --[[

        type:
        1 = 2 places
        2 = 4 places
        3 = 6 places
        4 = 10 places

        --]]
        { entry = vector3(133.14, -1082.21, 29.19), out = { pos = vector3(141.72, -1081.96, 29.19), heading = 1.6 }, price = 150000, name = "Garage place des cubes", type = 3 },
        { entry = vector3(-19.64, -1019.99, 28.91), out = { pos = vector3(-10.29, -1025.57, 29.0), heading = 246.0 }, price = 150000, name = "Garage paumé", type = 2 }
    }
}