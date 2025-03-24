let
    // 1. Obtener la fecha actual.
    Hoy = Date.From(DateTime.LocalNow()),

    // 2. Definir el rango de fechas desde el 1 de enero de 2010 hasta el final del año actual.
    FechaInicio = #date(2010, 1, 1),  // Fecha de inicio: 1 de enero de 2010.
    FechaFin = Date.EndOfYear(Hoy),   // Fecha de fin: último día del año actual.

    // 3. Crear una lista de fechas desde FechaInicio hasta FechaFin.
    ListaFechas = List.Dates(FechaInicio, Duration.Days(FechaFin - FechaInicio) + 1, #duration(1, 0, 0, 0)),

    // 4. Convertir la lista de fechas en una tabla con una columna llamada "Fecha".
    TablaFechas = Table.FromList(ListaFechas, Splitter.SplitByNothing(), type table [Fecha = Date.Type]),

    // 5. Añadir una columna que contenga el año de cada fecha.
    AñadirAño = Table.AddColumn(TablaFechas, "Año", each Date.Year([Fecha]), Int64.Type),

    // 6. Añadir una columna con el número de trimestre correspondiente a cada fecha.
    AñadirNumeroTrimestre = Table.AddColumn(
        AñadirAño, "Número de Trimestre", each Date.QuarterOfYear([Fecha]), Int64.Type
    ),

    // 7. Añadir una columna con el trimestre en formato "T" seguido del número de trimestre (ej. T1, T2, T3, T4).
    AñadirTrimestre = Table.AddColumn(
        AñadirNumeroTrimestre, "Trimestre", each "T" & Text.From(Date.QuarterOfYear([Fecha])), type text
    ),

    // 8. Añadir una columna con el número del mes (1 = Enero, 2 = Febrero, ..., 12 = Diciembre).
    AñadirNumeroMes = Table.AddColumn(AñadirTrimestre, "Mes del Año", each Date.Month([Fecha]), Int64.Type),

    // 9. Añadir una columna con el nombre del mes en español (ej. Enero, Febrero, etc.).
    AñadirNombreMes = Table.AddColumn(AñadirNumeroMes, "Mes", each Date.MonthName([Fecha], "es-ES"), type text),

    // 10. Añadir una columna con el nombre abreviado del mes en español (ej. Ene, Feb, ...).
    AñadirNombreMesAbreviado = Table.AddColumn(
        AñadirNombreMes, "Mes abreviado", each Date.ToText([Fecha], "MMM", "es-ES"), type text
    ),

    // 11. Añadir una columna con la fecha de inicio de cada mes (el primer día de cada mes).
    AñadirInicioMes = Table.AddColumn(
        AñadirNombreMesAbreviado, "Inicio de Mes", each Date.StartOfMonth([Fecha]), type date
    ),

    // 12. Añadir una columna con la fecha de fin de mes (el último día de cada mes).
    AñadirFinMes = Table.AddColumn(AñadirInicioMes, "Fin de Mes", each Date.EndOfMonth([Fecha]), type date),

    // 13. Añadir una columna con la fecha de inicio de la semana (usando el lunes como primer día de la semana).
    AñadirInicioSemana = Table.AddColumn(
        AñadirFinMes, "Inicio de Semana", each Date.StartOfWeek([Fecha], Day.Monday), type date
    ),

    // 14. Añadir una columna con el nombre del día de la semana en español (ej. Lunes, Martes, ...).
    AñadirNombreDia = Table.AddColumn(
        AñadirInicioSemana, "Nombre del Día", each Date.DayOfWeekName([Fecha], "es-ES"), type text
    ),

    // 15. Añadir una columna con el número del día del mes (del 1 al 31).
    AñadirNumeroDiaMes = Table.AddColumn(
        AñadirNombreDia, "Número de Día del Mes", each Date.Day([Fecha]), Int64.Type
    ),

    // 16. Añadir una columna con el número del día de la semana (de 0 a 6, siendo 0 el lunes).
    AñadirDiaSemana = Table.AddColumn(AñadirNumeroDiaMes, "Dia semana", each Date.DayOfWeek([Fecha],1), Int64.Type),

    // 17. Añadir una columna con el número de semana ISO (la semana que contiene el primer jueves del año).
    AñadirSemanaISO = Table.AddColumn(
        AñadirDiaSemana,
        "Número de Semana ISO",
        each
            let
                // Calcular el jueves de la semana.
                JuevesActual = Date.AddDays([Fecha], 3 - Date.DayOfWeek([Fecha], Day.Monday)),
                AñoJuevesActual = Date.Year(JuevesActual),
                // Calcular el primer jueves del año.
                PrimerJuevesAño = Date.AddDays(
                    #date(AñoJuevesActual, 1, 7), -Date.DayOfWeek(#date(AñoJuevesActual, 1, 1), Day.Friday)
                ),
                // Calcular el número de la semana ISO.
                SemanaISO = Duration.Days(JuevesActual - PrimerJuevesAño) / 7 + 1
            in
                SemanaISO,
        Int64.Type
    ),

    // 18. Añadir una columna con el año ISO, basado en la fecha y número de semana ISO.
    AñadirAñoISO = Table.AddColumn(
        AñadirSemanaISO, "Año ISO", each Date.Year(Date.AddDays([Fecha], 26 - [Número de Semana ISO])), Int64.Type
    )
in
    AñadirAñoISO