class MesureModel {
  Patient? patient;
  List<Pathologies>? pathologies;
  PressionArterielle? pressionArterielle;
  FrequenceCardiaque? frequenceCardiaque;
  Glycemie? glycemie;
  Poids? poids;
  Imc? imc;

  MesureModel({
    this.patient,
    this.pathologies,
    this.pressionArterielle,
    this.frequenceCardiaque,
    this.glycemie,
    this.poids,
    this.imc,
  });

  MesureModel.fromJson(Map<String, dynamic> json) {
    patient =
        json['patient'] != null ? Patient.fromJson(json['patient']) : null;
    if (json['pathologies'] != null) {
      pathologies = <Pathologies>[];
      json['pathologies'].forEach((v) {
        pathologies!.add(Pathologies.fromJson(v));
      });
    }
    pressionArterielle =
        json['pression_arterielle'] != null
            ? PressionArterielle.fromJson(json['pression_arterielle'])
            : null;
    frequenceCardiaque =
        json['frequence_cardiaque'] != null
            ? FrequenceCardiaque.fromJson(json['frequence_cardiaque'])
            : null;
    glycemie =
        json['glycemie'] != null
            ? Glycemie.fromJson(json['glycemie'])
            : null;
    poids = json['poids'] != null ? Poids.fromJson(json['poids']) : null;
    imc = json['imc'] != null ? Imc.fromJson(json['imc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (patient != null) {
      data['patient'] = patient!.toJson();
    }
    if (pathologies != null) {
      data['pathologies'] = pathologies!.map((v) => v.toJson()).toList();
    }
    if (pressionArterielle != null) {
      data['pression_arterielle'] = pressionArterielle!.toJson();
    }
    if (frequenceCardiaque != null) {
      data['frequence_cardiaque'] = frequenceCardiaque!.toJson();
    }
    if (glycemie != null) {
      data['glycemie'] = glycemie!.toJson();
    }
    if (poids != null) {
      data['poids'] = poids!.toJson();
    }
    if (imc != null) {
      data['imc'] = imc!.toJson();
    }
    return data;
  }
}

class Patient {
  int? id;
  String? nom;
  String? tailleCm;

  Patient({this.id, this.nom, this.tailleCm});

  Patient.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    tailleCm = json['taille_cm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['taille_cm'] = tailleCm;
    return data;
  }
}

class Pathologies {
  String? code;
  String? nom;
  String? priority;

  Pathologies({this.code, this.nom, this.priority});

  Pathologies.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    nom = json['nom'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['nom'] = nom;
    data['priority'] = priority;
    return data;
  }
}

class PressionArterielle {
  CurrentPression? currentPression;
  ChartPression? chartPression;
  List<HistoryPression>? historyPression;

  PressionArterielle({
    this.currentPression,
    this.chartPression,
    this.historyPression,
  });

  PressionArterielle.fromJson(Map<String, dynamic> json) {
    currentPression =
        json['current_pression'] != null
            ? CurrentPression.fromJson(json['current_pression'])
            : null;
    chartPression =
        json['chart_pression'] != null
            ? ChartPression.fromJson(json['chart_pression'])
            : null;
    if (json['history_pression'] != null) {
      historyPression = <HistoryPression>[];
      json['history_pression'].forEach((v) {
        historyPression!.add(HistoryPression.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentPression != null) {
      data['current_pression'] = currentPression!.toJson();
    }
    if (chartPression != null) {
      data['chart_pression'] = chartPression!.toJson();
    }
    if (historyPression != null) {
      data['history_pression'] =
          historyPression!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrentPression {
  String? value;
  String? unit;
  String? date;
  String? status;

  CurrentPression({this.value, this.unit, this.date, this.status});

  CurrentPression.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}

class ChartPression {
  List<String>? labels;
  List<int>? systolic;
  List<int>? diastolic;

  ChartPression({this.labels, this.systolic, this.diastolic});

  ChartPression.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    systolic = json['systolic'].cast<int>();
    diastolic = json['diastolic'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['labels'] = labels;
    data['systolic'] = systolic;
    data['diastolic'] = diastolic;
    return data;
  }
}

class HistoryPression {
  int? systolic;
  int? diastolic;
  String? date;
  String? status;

  HistoryPression({this.systolic, this.diastolic, this.date, this.status});

  HistoryPression.fromJson(Map<String, dynamic> json) {
    systolic = json['systolic'];
    diastolic = json['diastolic'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['systolic'] = systolic;
    data['diastolic'] = diastolic;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}

class FrequenceCardiaque {
  CurrentFrequence? currentFrequence;
  ChartFrequence? chartFrequence;
  List<HistoryFrequence>? historyFrequence;

  FrequenceCardiaque({
    this.currentFrequence,
    this.chartFrequence,
    this.historyFrequence,
  });

  FrequenceCardiaque.fromJson(Map<String, dynamic> json) {
    currentFrequence =
        json['current_frequence'] != null
            ? CurrentFrequence.fromJson(json['current_frequence'])
            : null;
    chartFrequence =
        json['chart_frequence'] != null
            ? ChartFrequence.fromJson(json['chart_frequence'])
            : null;
    if (json['history_frequence'] != null) {
      historyFrequence = <HistoryFrequence>[];
      json['history_frequence'].forEach((v) {
        historyFrequence!.add(HistoryFrequence.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentFrequence != null) {
      data['current_frequence'] = currentFrequence!.toJson();
    }
    if (chartFrequence != null) {
      data['chart_frequence'] = chartFrequence!.toJson();
    }
    if (historyFrequence != null) {
      data['history_frequence'] =
          historyFrequence!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryFrequence {
  int? value;
  String? unit;
  String? date;
  String? status;

  HistoryFrequence({this.value, this.unit, this.date, this.status});

  HistoryFrequence.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['diastolic'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}

class CurrentFrequence {
  int? value;
  String? unit;
  String? date;
  String? status;

  CurrentFrequence({this.value, this.unit, this.date, this.status});

  CurrentFrequence.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}

class ChartFrequence {
  List<String>? labels;
  List<int>? values;

  ChartFrequence({this.labels, this.values});

  ChartFrequence.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    values = json['values'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['labels'] = labels;
    data['values'] = values;
    return data;
  }
}

class Glycemie {
  CurrentGlycemie? currentGlycemie;
  ChartGlycemie? chartGlycemie;
  List<HistoryGlycemie>? historyGlycemie;

  Glycemie({this.currentGlycemie, this.chartGlycemie, this.historyGlycemie});

  Glycemie.fromJson(Map<String, dynamic> json) {
    currentGlycemie =
        json['current_glycemie'] != null
            ? CurrentGlycemie.fromJson(json['current_glycemie'])
            : null;
    chartGlycemie =
        json['chart_glycemie'] != null
            ? ChartGlycemie.fromJson(json['chart_glycemie'])
            : null;
    if (json['history_glycemie'] != null) {
      historyGlycemie = <HistoryGlycemie>[];
      json['history_glycemie'].forEach((v) {
        historyGlycemie!.add(HistoryGlycemie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentGlycemie != null) {
      data['current_glycemie'] = currentGlycemie!.toJson();
    }
    if (chartGlycemie != null) {
      data['chart_glycemie'] = chartGlycemie!.toJson();
    }
    if (historyGlycemie != null) {
      data['history_glycemie'] =
          historyGlycemie!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryGlycemie {
  String? value;
  String? unit;
  String? date;
  String? status;
  int? isFasting;

  HistoryGlycemie({
    this.value,
    this.unit,
    this.date,
    this.status,
    this.isFasting,
  });

  HistoryGlycemie.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['diastolic'];
    date = json['date'];
    status = json['status'];
    isFasting = json['is_fasting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    data['is_fasting'] = isFasting;
    return data;
  }
}

class CurrentGlycemie {
  String? value;
  String? unit;
  String? date;
  String? status;
  int? isFasting;

  CurrentGlycemie({
    this.value,
    this.unit,
    this.date,
    this.status,
    this.isFasting,
  });

  CurrentGlycemie.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
    date = json['date'];
    status = json['status'];
    isFasting = json['is_fasting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    data['is_fasting'] = isFasting;
    return data;
  }
}

class ChartGlycemie {
  List<String>? labels;
  List<String>? values;

  ChartGlycemie({this.labels, this.values});

  ChartGlycemie.fromJson(Map<String, dynamic> json) {
    labels = json['labels'].cast<String>();
    values = json['values'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['labels'] = labels;
    data['values'] = values;
    return data;
  }
}

class Poids {
  CurrentPression? currentPoids;
  ChartGlycemie? chartPoids;
  List<HistoryPoids>? historyPoids;

  Poids({this.currentPoids, this.chartPoids, this.historyPoids});

  Poids.fromJson(Map<String, dynamic> json) {
    currentPoids =
        json['current_poids'] != null
            ? CurrentPression.fromJson(json['current_poids'])
            : null;
    chartPoids =
        json['chart_poids'] != null
            ? ChartGlycemie.fromJson(json['chart_poids'])
            : null;
    if (json['history_poids'] != null) {
      historyPoids = <HistoryPoids>[];
      json['history_poids'].forEach((v) {
        historyPoids!.add(HistoryPoids.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentPoids != null) {
      data['current_poids'] = currentPoids!.toJson();
    }
    if (chartPoids != null) {
      data['chart_poids'] = chartPoids!.toJson();
    }
    if (historyPoids != null) {
      data['history_poids'] =
          historyPoids!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryPoids {
  String? value;
  String? unit;
  String? date;
  String? status;

  HistoryPoids({this.value, this.unit, this.date, this.status});

  HistoryPoids.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['diastolic'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}

class Imc {
  CurrentPression? currentImc;
  ChartGlycemie? chartImc;
  List<HistoryImc>? historyImc;

  Imc({this.currentImc, this.chartImc, this.historyImc});

  Imc.fromJson(Map<String, dynamic> json) {
    currentImc =
        json['current_imc'] != null
            ? CurrentPression.fromJson(json['current_imc'])
            : null;
    chartImc =
        json['chart_imc'] != null
            ? ChartGlycemie.fromJson(json['chart_imc'])
            : null;
    if (json['history_imc'] != null) {
      historyImc = <HistoryImc>[];
      json['history_imc'].forEach((v) {
        historyImc!.add(HistoryImc.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (currentImc != null) {
      data['current_imc'] = currentImc!.toJson();
    }
    if (chartImc != null) {
      data['chart_imc'] = chartImc!.toJson();
    }
    if (historyImc != null) {
      data['history_imc'] = historyImc!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryImc {
  String? value;
  String? unit;
  String? date;
  String? status;

  HistoryImc({this.value, this.unit, this.date, this.status});

  HistoryImc.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['diastolic'];
    date = json['date'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['unit'] = unit;
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}
