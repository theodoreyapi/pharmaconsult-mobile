class BilanModel {
  Periode? periode;
  ResumeGlobal? resumeGlobal;
  PressionArterielle? pressionArterielle;
  FrequenceCardiaque? frequenceCardiaque;
  Glycemie? glycemie;
  Poids? poids;
  Imc? imc;

  BilanModel({
    this.periode,
    this.resumeGlobal,
    this.pressionArterielle,
    this.frequenceCardiaque,
    this.glycemie,
    this.poids,
    this.imc,
  });

  BilanModel.fromJson(Map<String, dynamic> json) {
    periode =
        json['periode'] != null ? Periode.fromJson(json['periode']) : null;
    resumeGlobal =
        json['resume_global'] != null
            ? ResumeGlobal.fromJson(json['resume_global'])
            : null;
    pressionArterielle =
        json['pression_arterielle'] != null
            ? PressionArterielle.fromJson(json['pression_arterielle'])
            : null;
    frequenceCardiaque =
        json['frequence_cardiaque'] != null
            ? FrequenceCardiaque.fromJson(json['frequence_cardiaque'])
            : null;
    glycemie =
        json['glycemie'] != null ? Glycemie.fromJson(json['glycemie']) : null;
    poids = json['poids'] != null ? Poids.fromJson(json['poids']) : null;
    imc = json['imc'] != null ? Imc.fromJson(json['imc']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (periode != null) {
      data['periode'] = periode!.toJson();
    }
    if (resumeGlobal != null) {
      data['resume_global'] = resumeGlobal!.toJson();
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

class Periode {
  String? startDate;
  String? endDate;
  int? totalMesures;

  Periode({this.startDate, this.endDate, this.totalMesures});

  Periode.fromJson(Map<String, dynamic> json) {
    startDate = json['start_date'];
    endDate = json['end_date'];
    totalMesures = json['total_mesures'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['total_mesures'] = totalMesures;
    return data;
  }
}

class ResumeGlobal {
  int? normales;
  int? attention;
  int? elevees;

  ResumeGlobal({this.normales, this.attention, this.elevees});

  ResumeGlobal.fromJson(Map<String, dynamic> json) {
    normales = json['normales'];
    attention = json['attention'];
    elevees = json['elevees'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['normales'] = normales;
    data['attention'] = attention;
    data['elevees'] = elevees;
    return data;
  }
}

class PressionArterielle {
  int? count;
  int? averageSystolic;
  int? averageDiastolic;
  String? lastMeasure;
  String? trend;
  ResumeGlobal? status;

  PressionArterielle({
    this.count,
    this.averageSystolic,
    this.averageDiastolic,
    this.lastMeasure,
    this.trend,
    this.status,
  });

  PressionArterielle.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    averageSystolic = json['average_systolic'];
    averageDiastolic = json['average_diastolic'];
    lastMeasure = json['last_measure'];
    trend = json['trend'];
    status =
        json['status'] != null ? ResumeGlobal.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['average_systolic'] = averageSystolic;
    data['average_diastolic'] = averageDiastolic;
    data['last_measure'] = lastMeasure;
    data['trend'] = trend;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}

class FrequenceCardiaque {
  int? count;
  int? average;
  int? last;
  int? min;
  int? max;
  String? trend;
  ResumeGlobal? status;

  FrequenceCardiaque({
    this.count,
    this.average,
    this.last,
    this.min,
    this.max,
    this.trend,
    this.status,
  });

  FrequenceCardiaque.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    average = json['average'];
    last = json['last'];
    min = json['min'];
    max = json['max'];
    trend = json['trend'];
    status =
        json['status'] != null ? ResumeGlobal.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['average'] = average;
    data['last'] = last;
    data['min'] = min;
    data['max'] = max;
    data['trend'] = trend;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}

class Glycemie {
  int? count;
  double? average;
  String? last;
  String? min;
  String? max;
  String? trend;
  ResumeGlobal? status;

  Glycemie({
    this.count,
    this.average,
    this.last,
    this.min,
    this.max,
    this.trend,
    this.status,
  });

  Glycemie.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    average = json['average'];
    last = json['last'];
    min = json['min'];
    max = json['max'];
    trend = json['trend'];
    status =
        json['status'] != null ? ResumeGlobal.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['average'] = average;
    data['last'] = last;
    data['min'] = min;
    data['max'] = max;
    data['trend'] = trend;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}

class Poids {
  int? count;
  int? average;
  String? last;
  String? min;
  String? max;
  String? trend;
  ResumeGlobal? status;

  Poids({
    this.count,
    this.average,
    this.last,
    this.min,
    this.max,
    this.trend,
    this.status,
  });

  Poids.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    average = json['average'];
    last = json['last'];
    min = json['min'];
    max = json['max'];
    trend = json['trend'];
    status =
        json['status'] != null ? ResumeGlobal.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['average'] = average;
    data['last'] = last;
    data['min'] = min;
    data['max'] = max;
    data['trend'] = trend;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}

class Imc {
  int? count;
  double? average;
  String? last;
  String? min;
  String? max;
  String? trend;
  ResumeGlobal? status;

  Imc({
    this.count,
    this.average,
    this.last,
    this.min,
    this.max,
    this.trend,
    this.status,
  });

  Imc.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    average = json['average'];
    last = json['last'];
    min = json['min'];
    max = json['max'];
    trend = json['trend'];
    status =
        json['status'] != null ? ResumeGlobal.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['average'] = average;
    data['last'] = last;
    data['min'] = min;
    data['max'] = max;
    data['trend'] = trend;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    return data;
  }
}
